//
//  RecipeScraper.swift
//  Chow
//
//  Fetches a recipe URL and extracts name, image, ingredients & servings,
//  primarily via schema.org JSON-LD with HTML meta-tag fallbacks.
//

import Foundation

/// The result of scraping a recipe page.
nonisolated struct ScrapedRecipe: Sendable {
    var name: String
    var sourceSite: String
    var sourceURL: String
    var imageURL: String?
    var servings: Int
    var ingredients: [ScrapedIngredient]
}

nonisolated struct ScrapedIngredient: Sendable {
    var name: String
    var quantity: Double?
    var unit: String?
}

nonisolated enum RecipeScrapeError: LocalizedError {
    case badURL
    case network
    case notFound

    nonisolated var errorDescription: String? {
        switch self {
        case .badURL: "That doesn't look like a valid link. Double-check it!"
        case .network: "Couldn't reach that page. Check your connection and try again."
        case .notFound: "We couldn't find a recipe on that page. Try a direct recipe link!"
        }
    }
}

/// Stateless recipe scraping service. All work is `nonisolated` so it runs off the main actor.
nonisolated enum RecipeScraper {

    static func scrape(urlString: String) async throws -> ScrapedRecipe {
        var normalized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalized.lowercased().hasPrefix("http") {
            normalized = "https://" + normalized
        }
        guard let url = URL(string: normalized) else {
            throw RecipeScrapeError.badURL
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )
        request.timeoutInterval = 20

        let html: String
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            html = String(decoding: data, as: UTF8.self)
        } catch {
            throw RecipeScrapeError.network
        }

        let host = url.host?.replacingOccurrences(of: "www.", with: "") ?? "the web"

        if let recipe = parseJSONLD(html: html, host: host, sourceURL: normalized) {
            return recipe
        }

        // Fallback: build something usable from meta tags.
        let title = metaContent(html, property: "og:title")
            ?? firstMatch(html, pattern: "<title[^>]*>([^<]+)</title>")
            ?? "New Recipe"
        let image = metaContent(html, property: "og:image")

        return ScrapedRecipe(
            name: cleanText(title),
            sourceSite: host,
            sourceURL: normalized,
            imageURL: image,
            servings: 2,
            ingredients: []
        )
    }

    // MARK: - JSON-LD parsing

    private static func parseJSONLD(html: String, host: String, sourceURL: String) -> ScrapedRecipe? {
        let blocks = jsonLDBlocks(in: html)
        for block in blocks {
            guard let data = block.data(using: .utf8) else { continue }
            guard let json = try? JSONSerialization.jsonObject(with: data) else { continue }
            if let recipeDict = findRecipeDict(in: json) {
                return buildRecipe(from: recipeDict, host: host, sourceURL: sourceURL)
            }
        }
        return nil
    }

    /// Extract the raw JSON strings from all <script type="application/ld+json"> blocks.
    private static func jsonLDBlocks(in html: String) -> [String] {
        var results: [String] = []
        let pattern = "<script[^>]*type=[\"']application/ld\\+json[\"'][^>]*>([\\s\\S]*?)</script>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return results
        }
        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        regex.enumerateMatches(in: html, range: range) { match, _, _ in
            guard let match, let r = Range(match.range(at: 1), in: html) else { return }
            results.append(String(html[r]))
        }
        return results
    }

    /// Recursively search a decoded JSON structure for an object whose @type contains "Recipe".
    private static func findRecipeDict(in json: Any) -> [String: Any]? {
        if let dict = json as? [String: Any] {
            if let type = dict["@type"], typeContainsRecipe(type) {
                return dict
            }
            if let graph = dict["@graph"] {
                if let found = findRecipeDict(in: graph) { return found }
            }
            for value in dict.values {
                if let found = findRecipeDict(in: value) { return found }
            }
        } else if let array = json as? [Any] {
            for value in array {
                if let found = findRecipeDict(in: value) { return found }
            }
        }
        return nil
    }

    private static func typeContainsRecipe(_ type: Any) -> Bool {
        if let s = type as? String { return s.lowercased().contains("recipe") }
        if let arr = type as? [String] { return arr.contains { $0.lowercased().contains("recipe") } }
        return false
    }

    private static func buildRecipe(from dict: [String: Any], host: String, sourceURL: String) -> ScrapedRecipe {
        let name = cleanText((dict["name"] as? String) ?? "New Recipe")
        let image = extractImage(dict["image"])
        let servings = extractServings(dict["recipeYield"])
        let ingredientStrings = extractIngredients(dict["recipeIngredient"] ?? dict["ingredients"])
        let parsed = ingredientStrings.map { IngredientParser.parse($0) }

        return ScrapedRecipe(
            name: name,
            sourceSite: host,
            sourceURL: sourceURL,
            imageURL: image,
            servings: servings,
            ingredients: parsed
        )
    }

    private static func extractImage(_ value: Any?) -> String? {
        if let s = value as? String { return s }
        if let arr = value as? [Any] {
            for item in arr {
                if let s = item as? String { return s }
                if let d = item as? [String: Any], let u = d["url"] as? String { return u }
            }
        }
        if let dict = value as? [String: Any], let u = dict["url"] as? String { return u }
        return nil
    }

    private static func extractServings(_ value: Any?) -> Int {
        if let i = value as? Int { return max(1, i) }
        if let s = value as? String {
            if let n = firstInt(in: s) { return max(1, n) }
        }
        if let arr = value as? [Any] {
            for item in arr {
                if let i = item as? Int { return max(1, i) }
                if let s = item as? String, let n = firstInt(in: s) { return max(1, n) }
            }
        }
        return 2
    }

    private static func extractIngredients(_ value: Any?) -> [String] {
        if let arr = value as? [String] { return arr }
        if let arr = value as? [Any] { return arr.compactMap { $0 as? String } }
        if let s = value as? String { return [s] }
        return []
    }

    // MARK: - HTML helpers

    private static func metaContent(_ html: String, property: String) -> String? {
        let patterns = [
            "<meta[^>]*property=[\"']\(property)[\"'][^>]*content=[\"']([^\"']+)[\"']",
            "<meta[^>]*content=[\"']([^\"']+)[\"'][^>]*property=[\"']\(property)[\"']",
            "<meta[^>]*name=[\"']\(property)[\"'][^>]*content=[\"']([^\"']+)[\"']",
        ]
        for pattern in patterns {
            if let match = firstMatch(html, pattern: pattern) {
                return match
            }
        }
        return nil
    }

    private static func firstMatch(_ text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let r = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return cleanText(String(text[r]))
    }

    private static func firstInt(in s: String) -> Int? {
        let digits = s.prefix { !$0.isNumber }.isEmpty
        _ = digits
        var current = ""
        for ch in s {
            if ch.isNumber { current.append(ch) }
            else if !current.isEmpty { break }
        }
        return Int(current)
    }

    /// Decode common HTML entities and trim whitespace.
    private static func cleanText(_ raw: String) -> String {
        var s = raw
        let entities: [String: String] = [
            "&amp;": "&", "&quot;": "\"", "&#39;": "'", "&#x27;": "'",
            "&apos;": "'", "&nbsp;": " ", "&ndash;": "–", "&mdash;": "—",
            "&deg;": "°", "&frac12;": "½", "&frac14;": "¼", "&frac34;": "¾",
            "&lt;": "<", "&gt;": ">",
        ]
        for (entity, replacement) in entities {
            s = s.replacingOccurrences(of: entity, with: replacement)
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

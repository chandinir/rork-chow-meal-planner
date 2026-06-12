//
//  IngredientParser.swift
//  Chow
//
//  Parses freeform ingredient lines ("1 1/2 cups flour") into quantity/unit/name.
//

import Foundation

/// Parses raw ingredient strings into structured quantity, unit, and name.
nonisolated enum IngredientParser {

    private static let units: Set<String> = [
        "cup", "cups", "tablespoon", "tablespoons", "tbsp", "tbsp.", "teaspoon",
        "teaspoons", "tsp", "tsp.", "ounce", "ounces", "oz", "oz.", "pound",
        "pounds", "lb", "lbs", "lb.", "gram", "grams", "g", "kg", "kilogram",
        "kilograms", "ml", "milliliter", "milliliters", "liter", "liters", "l",
        "clove", "cloves", "slice", "slices", "pinch", "can", "cans", "package",
        "packages", "pkg", "stick", "sticks", "bunch", "head", "handful", "dash",
        "quart", "quarts", "pint", "pints", "gallon", "fl", "sprig", "sprigs",
    ]

    nonisolated static func parse(_ raw: String) -> ScrapedIngredient {
        var working = raw
            .replacingOccurrences(of: "½", with: " 1/2")
            .replacingOccurrences(of: "¼", with: " 1/4")
            .replacingOccurrences(of: "¾", with: " 3/4")
            .replacingOccurrences(of: "⅓", with: " 1/3")
            .replacingOccurrences(of: "⅔", with: " 2/3")
            .replacingOccurrences(of: "⅛", with: " 1/8")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Drop parenthetical notes like "(about 2 cups)".
        if let openParen = working.firstIndex(of: "(") {
            // Keep content before parentheses for the leading quantity.
            let tail = working[working.index(after: openParen)...]
            if let closeParen = tail.firstIndex(of: ")") {
                let after = tail[tail.index(after: closeParen)...]
                working = String(working[..<openParen]) + " " + String(after)
            }
        }

        var tokens = working.split(separator: " ").map(String.init)
        guard !tokens.isEmpty else {
            return ScrapedIngredient(name: raw, quantity: nil, unit: nil)
        }

        var quantity: Double?

        // Parse leading quantity, including mixed numbers ("1 1/2") and fractions.
        if let first = parseNumber(tokens.first ?? "") {
            quantity = first
            tokens.removeFirst()
            // Mixed number: "1 1/2"
            if let second = tokens.first, let frac = parseNumber(second), second.contains("/") {
                quantity = (quantity ?? 0) + frac
                tokens.removeFirst()
            }
        }

        // Parse an optional unit token.
        var unit: String?
        if let candidate = tokens.first?.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: ".,")),
           units.contains(candidate) {
            unit = normalizeUnit(candidate)
            tokens.removeFirst()
        }

        // Remaining is the name; strip leading "of".
        if tokens.first?.lowercased() == "of" {
            tokens.removeFirst()
        }
        var name = tokens.joined(separator: " ")
        // Remove trailing preparation notes after a comma ("onion, diced").
        if let comma = name.firstIndex(of: ",") {
            name = String(name[..<comma])
        }
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { name = raw }

        return ScrapedIngredient(name: name, quantity: quantity, unit: unit)
    }

    private static func parseNumber(_ token: String) -> Double? {
        if token.contains("/") {
            let parts = token.split(separator: "/")
            if parts.count == 2, let n = Double(parts[0]), let d = Double(parts[1]), d != 0 {
                return n / d
            }
            return nil
        }
        return Double(token)
    }

    private static func normalizeUnit(_ unit: String) -> String {
        switch unit {
        case "tablespoon", "tablespoons", "tbsp.": "tbsp"
        case "teaspoon", "teaspoons", "tsp.": "tsp"
        case "ounce", "ounces", "oz.": "oz"
        case "pound", "pounds", "lbs", "lb.": "lb"
        case "cups": "cup"
        case "grams", "gram": "g"
        default: unit
        }
    }
}

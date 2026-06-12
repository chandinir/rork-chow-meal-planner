//
//  Ingredient.swift
//  Chow
//
//  A single recipe ingredient with an optional parsed quantity & unit.
//

import Foundation

/// A recipe ingredient. Stored as a Codable value type inside `Recipe`.
nonisolated struct Ingredient: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    /// Clean ingredient name (e.g. "carrot").
    var name: String
    /// Parsed numeric amount, if any (e.g. 2). Nil for "salt to taste".
    var quantity: Double?
    /// Parsed unit, if any (e.g. "cup", "g", "tbsp").
    var unit: String?
    /// Category for grouping on the grocery list.
    var category: GroceryCategory

    init(name: String, quantity: Double? = nil, unit: String? = nil, category: GroceryCategory? = nil) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = trimmed
        self.quantity = quantity
        self.unit = unit
        self.category = category ?? GroceryCategory.classify(trimmed)
    }

    /// A nicely formatted display string scaled by a multiplier.
    nonisolated func displayString(scale: Double = 1) -> String {
        var parts: [String] = []
        if let quantity, quantity > 0 {
            parts.append(Self.formatNumber(quantity * scale))
        }
        if let unit, !unit.isEmpty {
            parts.append(unit)
        }
        parts.append(name)
        return parts.joined(separator: " ")
    }

    /// Format a number trimming trailing zeros; show simple fractions for halves/quarters.
    nonisolated static func formatNumber(_ value: Double) -> String {
        let rounded = (value * 100).rounded() / 100
        if rounded == rounded.rounded() {
            return String(Int(rounded))
        }
        // Common fractions
        let whole = Int(rounded)
        let frac = rounded - Double(whole)
        let fractions: [(Double, String)] = [
            (0.25, "¼"), (0.33, "⅓"), (0.5, "½"), (0.66, "⅔"), (0.75, "¾"),
        ]
        for (val, symbol) in fractions where abs(frac - val) < 0.05 {
            return whole > 0 ? "\(whole)\(symbol)" : symbol
        }
        return String(format: "%.2g", rounded)
    }
}

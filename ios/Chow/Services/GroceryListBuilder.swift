//
//  GroceryListBuilder.swift
//  Chow
//
//  Combines & deduplicates scaled ingredients from all planned meals.
//

import Foundation

/// Builds a deduplicated grocery list from the week's planned meals.
nonisolated enum GroceryListBuilder {

    /// An aggregated grocery line ready to become a `GroceryItem`.
    nonisolated struct AggregatedItem {
        var name: String
        var quantity: Double?
        var unit: String?
        var category: GroceryCategory
    }

    /// Aggregate scaled ingredients across planned meals, merging by name + unit.
    nonisolated static func build(from meals: [(ingredients: [Ingredient], scale: Double)]) -> [AggregatedItem] {
        var merged: [String: AggregatedItem] = [:]
        var order: [String] = []

        for meal in meals {
            for ingredient in meal.ingredients {
                let normalizedName = ingredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !normalizedName.isEmpty else { continue }
                let unitKey = ingredient.unit?.lowercased() ?? ""
                let key = "\(normalizedName)|\(unitKey)"

                let scaledQty = ingredient.quantity.map { $0 * meal.scale }

                if var existing = merged[key] {
                    if let scaledQty {
                        existing.quantity = (existing.quantity ?? 0) + scaledQty
                    }
                    merged[key] = existing
                } else {
                    merged[key] = AggregatedItem(
                        name: ingredient.name,
                        quantity: scaledQty,
                        unit: ingredient.unit,
                        category: ingredient.category
                    )
                    order.append(key)
                }
            }
        }

        return order.compactMap { merged[$0] }
    }
}

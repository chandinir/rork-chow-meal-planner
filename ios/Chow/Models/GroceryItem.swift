//
//  GroceryItem.swift
//  Chow
//
//  A line item on the generated (or manually added) grocery list.
//

import Foundation
import SwiftData

/// A single item on the grocery list, either auto-generated from the meal plan or added by hand.
@Model
final class GroceryItem {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: Double?
    var unit: String?
    var categoryRaw: String = GroceryCategory.other.rawValue
    var isChecked: Bool = false
    /// True when the user added this item manually (preserved across regeneration).
    var isManual: Bool = false
    var sortIndex: Int = 0

    var category: GroceryCategory {
        get { GroceryCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        name: String,
        quantity: Double? = nil,
        unit: String? = nil,
        category: GroceryCategory = .other,
        isChecked: Bool = false,
        isManual: Bool = false
    ) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.categoryRaw = category.rawValue
        self.isChecked = isChecked
        self.isManual = isManual
    }

    /// A formatted display string for the line item.
    var displayString: String {
        var parts: [String] = []
        if let quantity, quantity > 0 {
            parts.append(Ingredient.formatNumber(quantity))
        }
        if let unit, !unit.isEmpty {
            parts.append(unit)
        }
        parts.append(name)
        return parts.joined(separator: " ")
    }
}

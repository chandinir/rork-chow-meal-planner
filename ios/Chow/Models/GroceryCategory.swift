//
//  GroceryCategory.swift
//  Chow
//
//  Cute named grocery categories with fun emoji headers.
//

import SwiftUI

/// A friendly grocery aisle category used to organize the shopping list.
nonisolated enum GroceryCategory: String, Codable, CaseIterable, Identifiable {
    case produce
    case meat
    case dairy
    case pantry
    case frozen
    case other

    nonisolated var id: String { rawValue }

    var title: String {
        switch self {
        case .produce: "Produce"
        case .meat: "Meat & Seafood"
        case .dairy: "Dairy & Eggs"
        case .pantry: "Pantry"
        case .frozen: "Frozen"
        case .other: "Other"
        }
    }

    var emoji: String {
        switch self {
        case .produce: "🥦"
        case .meat: "🥩"
        case .dairy: "🧀"
        case .pantry: "🫙"
        case .frozen: "🧊"
        case .other: "🛍️"
        }
    }

    /// Display order on the grocery list.
    var sortOrder: Int {
        switch self {
        case .produce: 0
        case .meat: 1
        case .dairy: 2
        case .pantry: 3
        case .frozen: 4
        case .other: 5
        }
    }

    /// Accent color used for category headers.
    var tint: Color {
        switch self {
        case .produce: Color(red: 0.45, green: 0.75, blue: 0.45)
        case .meat: Theme.coral
        case .dairy: Theme.golden
        case .pantry: Theme.tangerine
        case .frozen: Color(red: 0.45, green: 0.70, blue: 0.90)
        case .other: Theme.pink
        }
    }

    /// Classify a raw ingredient name into a category using keyword matching.
    nonisolated static func classify(_ rawName: String) -> GroceryCategory {
        let name = rawName.lowercased()

        func contains(_ words: [String]) -> Bool {
            words.contains { name.contains($0) }
        }

        if contains(["frozen", "ice cream", "popsicle", "frozen peas"]) {
            return .frozen
        }
        if contains([
            "chicken", "beef", "pork", "bacon", "sausage", "turkey", "lamb",
            "steak", "ground", "salmon", "shrimp", "tuna", "fish", "cod",
            "ham", "tofu", "tilapia", "prawn", "mince", "ribs", "chorizo",
        ]) {
            return .meat
        }
        if contains([
            "milk", "cheese", "butter", "cream", "yogurt", "yoghurt", "egg",
            "parmesan", "mozzarella", "cheddar", "feta", "ricotta", "sour cream",
            "half and half", "buttermilk", "mascarpone",
        ]) {
            return .dairy
        }
        if contains([
            "lettuce", "tomato", "onion", "garlic", "pepper", "carrot", "potato",
            "spinach", "broccoli", "cucumber", "celery", "kale", "avocado",
            "lemon", "lime", "apple", "banana", "berr", "mushroom", "zucchini",
            "cilantro", "parsley", "basil", "ginger", "scallion", "leek",
            "cabbage", "corn", "bean sprout", "herb", "chili", "jalape",
            "squash", "eggplant", "asparagus", "cauliflower", "orange", "mango",
            "grape", "peach", "pear", "shallot", "radish", "beet", "fruit",
            "vegetable",
        ]) {
            return .produce
        }
        if contains([
            "flour", "sugar", "salt", "oil", "rice", "pasta", "bread", "spice",
            "sauce", "vinegar", "stock", "broth", "can", "bean", "lentil",
            "honey", "syrup", "vanilla", "baking", "yeast", "oat", "cereal",
            "noodle", "ketchup", "mustard", "mayo", "soy", "paste", "powder",
            "cumin", "paprika", "cinnamon", "nutmeg", "seasoning", "stock cube",
            "tortilla", "cracker", "nut", "seed", "coconut", "chocolate", "cocoa",
            "wine", "water", "tea", "coffee", "quinoa",
        ]) {
            return .pantry
        }
        return .other
    }
}

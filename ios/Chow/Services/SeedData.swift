//
//  SeedData.swift
//  Chow
//
//  Starter recipes so the library feels alive on first launch.
//

import Foundation
import SwiftData

/// Seeds the library with a few cheerful starter recipes the first time the app runs.
nonisolated enum SeedData {

    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Recipe>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        for recipe in starterRecipes() {
            context.insert(recipe)
        }
        try? context.save()
    }

    @MainActor
    private static func starterRecipes() -> [Recipe] {
        [
            Recipe(
                name: "Sunny Lemon Pasta",
                sourceSite: "chow kitchen",
                emoji: "🍝",
                baseServings: 2,
                ingredients: [
                    Ingredient(name: "spaghetti", quantity: 8, unit: "oz"),
                    Ingredient(name: "lemon", quantity: 1),
                    Ingredient(name: "parmesan", quantity: 0.5, unit: "cup"),
                    Ingredient(name: "garlic", quantity: 2, unit: "clove"),
                    Ingredient(name: "olive oil", quantity: 2, unit: "tbsp"),
                    Ingredient(name: "parsley", quantity: 1, unit: "bunch"),
                ]
            ),
            Recipe(
                name: "Cozy Veggie Chili",
                sourceSite: "chow kitchen",
                emoji: "🌶️",
                baseServings: 4,
                ingredients: [
                    Ingredient(name: "black beans", quantity: 2, unit: "can"),
                    Ingredient(name: "diced tomatoes", quantity: 1, unit: "can"),
                    Ingredient(name: "onion", quantity: 1),
                    Ingredient(name: "bell pepper", quantity: 2),
                    Ingredient(name: "garlic", quantity: 3, unit: "clove"),
                    Ingredient(name: "cumin", quantity: 1, unit: "tbsp"),
                    Ingredient(name: "corn", quantity: 1, unit: "cup"),
                ]
            ),
            Recipe(
                name: "Honey Garlic Chicken",
                sourceSite: "chow kitchen",
                emoji: "🍗",
                baseServings: 4,
                ingredients: [
                    Ingredient(name: "chicken thighs", quantity: 1.5, unit: "lb"),
                    Ingredient(name: "honey", quantity: 3, unit: "tbsp"),
                    Ingredient(name: "garlic", quantity: 4, unit: "clove"),
                    Ingredient(name: "soy sauce", quantity: 3, unit: "tbsp"),
                    Ingredient(name: "rice", quantity: 2, unit: "cup"),
                    Ingredient(name: "ginger", quantity: 1, unit: "tbsp"),
                ]
            ),
            Recipe(
                name: "Rainbow Crunch Salad",
                sourceSite: "chow kitchen",
                emoji: "🥗",
                baseServings: 2,
                ingredients: [
                    Ingredient(name: "kale", quantity: 4, unit: "cup"),
                    Ingredient(name: "carrot", quantity: 2),
                    Ingredient(name: "avocado", quantity: 1),
                    Ingredient(name: "chickpeas", quantity: 1, unit: "can"),
                    Ingredient(name: "feta", quantity: 0.5, unit: "cup"),
                    Ingredient(name: "lemon", quantity: 1),
                ]
            ),
            Recipe(
                name: "Fluffy Morning Pancakes",
                sourceSite: "chow kitchen",
                emoji: "🥞",
                baseServings: 2,
                ingredients: [
                    Ingredient(name: "flour", quantity: 1.5, unit: "cup"),
                    Ingredient(name: "milk", quantity: 1.25, unit: "cup"),
                    Ingredient(name: "egg", quantity: 2),
                    Ingredient(name: "butter", quantity: 3, unit: "tbsp"),
                    Ingredient(name: "sugar", quantity: 2, unit: "tbsp"),
                    Ingredient(name: "baking powder", quantity: 1, unit: "tbsp"),
                ]
            ),
            Recipe(
                name: "Toasty Tomato Soup",
                sourceSite: "chow kitchen",
                emoji: "🍲",
                baseServings: 4,
                ingredients: [
                    Ingredient(name: "tomatoes", quantity: 2, unit: "can"),
                    Ingredient(name: "onion", quantity: 1),
                    Ingredient(name: "garlic", quantity: 2, unit: "clove"),
                    Ingredient(name: "vegetable broth", quantity: 2, unit: "cup"),
                    Ingredient(name: "cream", quantity: 0.5, unit: "cup"),
                    Ingredient(name: "basil", quantity: 1, unit: "bunch"),
                ]
            ),
        ]
    }
}

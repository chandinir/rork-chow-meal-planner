//
//  Recipe.swift
//  Chow
//
//  A saved recipe in the user's library.
//

import Foundation
import SwiftData

/// A recipe saved by the user, either seeded, scraped from a URL, or added manually.
@Model
final class Recipe {
    var id: UUID = UUID()
    var name: String = ""
    /// Friendly source label (e.g. "allrecipes.com").
    var sourceSite: String = ""
    /// Original URL the recipe was imported from, if any.
    var sourceURL: String?
    /// Remote thumbnail image URL.
    var imageURL: String?
    /// Emoji fallback shown when there is no thumbnail.
    var emoji: String = "🍽️"
    /// Number of servings the stored ingredient quantities represent.
    var baseServings: Int = 2
    /// Stored ingredient list (Codable value types).
    var ingredients: [Ingredient] = []
    var dateAdded: Date = Date()

    init(
        name: String,
        sourceSite: String = "",
        sourceURL: String? = nil,
        imageURL: String? = nil,
        emoji: String = "🍽️",
        baseServings: Int = 2,
        ingredients: [Ingredient] = []
    ) {
        self.name = name
        self.sourceSite = sourceSite
        self.sourceURL = sourceURL
        self.imageURL = imageURL
        self.emoji = emoji
        self.baseServings = max(1, baseServings)
        self.ingredients = ingredients
    }
}

//
//  PlannedMeal.swift
//  Chow
//
//  A recipe assigned to a specific day + meal slot in the weekly plan.
//

import Foundation
import SwiftData

/// Lunch or dinner slot within a day.
nonisolated enum MealType: String, Codable, CaseIterable, Identifiable {
    case lunch
    case dinner

    nonisolated var id: String { rawValue }

    var title: String {
        switch self {
        case .lunch: "Lunch"
        case .dinner: "Dinner"
        }
    }

    var emoji: String {
        switch self {
        case .lunch: "🥪"
        case .dinner: "🍝"
        }
    }
}

/// A single planned meal: a recipe placed into a day + meal slot with a serving count.
@Model
final class PlannedMeal {
    var id: UUID = UUID()
    /// 0 = Monday ... 6 = Sunday.
    var dayIndex: Int = 0
    var mealTypeRaw: String = MealType.lunch.rawValue
    var servings: Int = 2
    @Relationship(deleteRule: .nullify) var recipe: Recipe?

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .lunch }
        set { mealTypeRaw = newValue.rawValue }
    }

    init(dayIndex: Int, mealType: MealType, servings: Int, recipe: Recipe?) {
        self.dayIndex = dayIndex
        self.mealTypeRaw = mealType.rawValue
        self.servings = servings
        self.recipe = recipe
    }
}

/// Day-of-week metadata for the weekly planner.
nonisolated enum Weekday: Int, CaseIterable, Identifiable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    nonisolated var id: Int { rawValue }

    var fullName: String {
        switch self {
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        case .sunday: "Sunday"
        }
    }

    var shortName: String { String(fullName.prefix(3)) }

    var emoji: String {
        switch self {
        case .monday: "🌅"
        case .tuesday: "🌤️"
        case .wednesday: "🐪"
        case .thursday: "🌈"
        case .friday: "🎉"
        case .saturday: "🛌"
        case .sunday: "☀️"
        }
    }
}

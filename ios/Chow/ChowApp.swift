//
//  ChowApp.swift
//  Chow
//
//  Created by Rork on June 9, 2026.
//

import SwiftUI
import SwiftData

@main
struct ChowApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recipe.self,
            PlannedMeal.self,
            GroceryItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

//
//  ContentView.swift
//  Chow
//
//  Created by Rork on June 9, 2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RootView()
            .tint(Theme.coral)
            .onAppear {
                SeedData.seedIfNeeded(context: modelContext)
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, PlannedMeal.self, GroceryItem.self], inMemory: true)
}

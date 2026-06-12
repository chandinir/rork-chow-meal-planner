//
//  RecipesView.swift
//  Chow
//
//  A warm visual card grid of all saved recipes.
//

import SwiftUI
import SwiftData

struct RecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.dateAdded, order: .reverse) private var recipes: [Recipe]

    @State private var showAddRecipe = false
    @State private var selectedRecipe: Recipe?

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    header

                    if recipes.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(recipes) { recipe in
                                Button {
                                    Haptics.tap()
                                    selectedRecipe = recipe
                                } label: {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(.pressable(scale: 0.95))
                            }
                        }
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
                .padding(.trailing, 24)
                .padding(.bottom, 96)
        }
        .sheet(isPresented: $showAddRecipe) {
            AddRecipeView { recipe in
                modelContext.insert(recipe)
                try? modelContext.save()
                Haptics.success()
            }
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe) {
                modelContext.delete(recipe)
                try? modelContext.save()
                selectedRecipe = nil
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Recipes")
                    .font(.chow(34, .heavy))
                    .foregroundStyle(Theme.ink)
                Text(recipes.isEmpty ? "Let's build your cookbook 📖" : "\(recipes.count) tasty ideas saved")
                    .font(.chow(15, .semibold))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer()
            Text("📖").font(.system(size: 44)).rotationEffect(.degrees(-6))
        }
        .padding(.top, 6)
    }

    private var addButton: some View {
        Button {
            Haptics.tap()
            showAddRecipe = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Theme.warmGlow)
                .clipShape(Circle())
                .shadow(color: Theme.coral.opacity(0.45), radius: 12, y: 6)
        }
        .buttonStyle(.pressable(scale: 0.88))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🍲").font(.system(size: 72))
            Text("No recipes yet")
                .font(.chow(24, .heavy))
                .foregroundStyle(Theme.ink)
            Text("Tap the + button to paste a recipe link. Chow will grab the name, photo & ingredients for you!")
                .font(.chow(15, .medium))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.top, 60)
    }
}

private struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.white
                .frame(height: 120)
                .overlay {
                    if let urlString = recipe.imageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                        } placeholder: {
                            ZStack {
                                Theme.peach.opacity(0.3)
                                Text(recipe.emoji).font(.system(size: 44))
                            }
                        }
                    } else {
                        ZStack {
                            LinearGradient(colors: [Theme.golden.opacity(0.4), Theme.peach.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                            Text(recipe.emoji).font(.system(size: 50))
                        }
                    }
                }
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.chow(16, .bold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(recipe.sourceSite.isEmpty ? "saved recipe" : recipe.sourceSite)
                    .font(.chow(12, .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .lineLimit(1)
            }
            .padding(12)
        }
        .background(Theme.card)
        .clipShape(.rect(cornerRadius: 22))
        .shadow(color: Theme.cardShadow, radius: 12, x: 0, y: 6)
    }
}

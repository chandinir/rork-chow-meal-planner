//
//  RecipeDetailView.swift
//  Chow
//
//  Full recipe details with thumbnail, ingredients & source.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    private var groupedIngredients: [(category: GroceryCategory, items: [Ingredient])] {
        let grouped = Dictionary(grouping: recipe.ingredients, by: { $0.category })
        return GroceryCategory.allCases
            .compactMap { category in
                guard let items = grouped[category], !items.isEmpty else { return nil }
                return (category, items)
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroImage

                        VStack(alignment: .leading, spacing: 6) {
                            Text(recipe.name)
                                .font(.chow(28, .heavy))
                                .foregroundStyle(Theme.ink)
                            HStack(spacing: 12) {
                                Label("Serves \(recipe.baseServings)", systemImage: "person.2.fill")
                                Label("\(recipe.ingredients.count) items", systemImage: "carrot.fill")
                            }
                            .font(.chow(13, .semibold))
                            .foregroundStyle(Theme.inkSoft)
                            if !recipe.sourceSite.isEmpty {
                                Text("from \(recipe.sourceSite)")
                                    .font(.chow(13, .medium))
                                    .foregroundStyle(Theme.coral)
                            }
                        }

                        ingredientsCard

                        if let sourceURL = recipe.sourceURL, let url = URL(string: sourceURL) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "safari.fill")
                                    Text("View original recipe")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .font(.chow(15, .bold))
                                .foregroundStyle(Theme.coral)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Theme.golden.opacity(0.18))
                                .clipShape(.rect(cornerRadius: 16))
                            }
                        }

                        Button(role: .destructive) {
                            Haptics.warning()
                            showDeleteConfirm = true
                        } label: {
                            Text("Delete Recipe")
                                .font(.chow(15, .bold))
                                .foregroundStyle(Theme.coral)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                    .padding(18)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.chow(16, .bold))
                        .foregroundStyle(Theme.coral)
                }
            }
            .confirmationDialog("Delete this recipe?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { onDelete() }
                Button("Keep it", role: .cancel) {}
            }
        }
    }

    private var heroImage: some View {
        Color.white
            .frame(height: 220)
            .overlay {
                if let urlString = recipe.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                    } placeholder: {
                        ZStack { Theme.peach.opacity(0.3); Text(recipe.emoji).font(.system(size: 64)) }
                    }
                } else {
                    ZStack {
                        LinearGradient(colors: [Theme.golden.opacity(0.45), Theme.peach.opacity(0.45)], startPoint: .top, endPoint: .bottom)
                        Text(recipe.emoji).font(.system(size: 80))
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 24))
            .shadow(color: Theme.cardShadow, radius: 12, y: 6)
    }

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ingredients")
                .font(.chow(20, .heavy))
                .foregroundStyle(Theme.ink)

            if recipe.ingredients.isEmpty {
                Text("No ingredients listed for this recipe.")
                    .font(.chow(14, .medium))
                    .foregroundStyle(Theme.inkSoft)
            } else {
                ForEach(groupedIngredients, id: \.category) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(group.category.emoji) \(group.category.title)")
                            .font(.chow(13, .bold))
                            .foregroundStyle(group.category.tint)
                        ForEach(group.items) { ingredient in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(group.category.tint.opacity(0.5))
                                    .frame(width: 7, height: 7)
                                Text(ingredient.displayString())
                                    .font(.chow(15, .semibold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .chowCard()
    }
}

//
//  RecipePickerView.swift
//  Chow
//
//  Sheet for choosing a recipe and serving size to fill a meal slot.
//

import SwiftUI

struct RecipePickerView: View {
    let recipes: [Recipe]
    /// Recipe to pre-select (e.g. when adjusting servings for an already-planned meal).
    var initialRecipe: Recipe? = nil
    /// Initial servings to show when a recipe is pre-selected.
    var initialServings: Int = 2
    let onPick: (Recipe, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selected: Recipe?
    @State private var servings: Int = 2
    @State private var didApplyInitial = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if recipes.isEmpty {
                    emptyState
                } else if let selected {
                    servingPicker(for: selected)
                } else {
                    recipeList
                }
            }
            .onAppear {
                guard !didApplyInitial else { return }
                didApplyInitial = true
                if let initial = initialRecipe {
                    selected = initial
                    servings = initialServings
                }
            }
            .navigationTitle(selected == nil ? "Pick a Recipe" : "How many servings?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if selected != nil {
                        Button("Back") {
                            Haptics.tap()
                            withAnimation(.snappy) { selected = nil }
                        }
                        .foregroundStyle(Theme.coral)
                    } else {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(Theme.inkSoft)
                    }
                }
            }
        }
    }

    private var recipeList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(recipes) { recipe in
                    Button {
                        Haptics.tap()
                        servings = recipe.baseServings
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selected = recipe
                        }
                    } label: {
                        HStack(spacing: 14) {
                            RecipeThumbnail(recipe: recipe, size: 56)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(recipe.name)
                                    .font(.chow(17, .bold))
                                    .foregroundStyle(Theme.ink)
                                    .lineLimit(1)
                                Text("\(recipe.ingredients.count) ingredients · serves \(recipe.baseServings)")
                                    .font(.chow(13, .medium))
                                    .foregroundStyle(Theme.inkSoft)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.golden)
                        }
                        .chowCard(padding: 12, cornerRadius: 20)
                    }
                    .buttonStyle(.pressable(scale: 0.97))
                }
            }
            .padding(18)
        }
    }

    private func servingPicker(for recipe: Recipe) -> some View {
        VStack(spacing: 24) {
            RecipeThumbnail(recipe: recipe, size: 110)
                .padding(.top, 12)
            Text(recipe.name)
                .font(.chow(22, .heavy))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)

            HStack(spacing: 24) {
                stepperButton(systemName: "minus") {
                    if servings > 1 { servings -= 1; Haptics.tap() }
                }
                VStack(spacing: 0) {
                    Text("\(servings)")
                        .font(.chow(52, .heavy))
                        .foregroundStyle(Theme.coral)
                        .contentTransition(.numericText(value: Double(servings)))
                    Text(servings == 1 ? "serving" : "servings")
                        .font(.chow(14, .semibold))
                        .foregroundStyle(Theme.inkSoft)
                }
                .frame(width: 120)
                stepperButton(systemName: "plus") {
                    if servings < 20 { servings += 1; Haptics.tap() }
                }
            }
            .animation(.snappy, value: servings)

            if servings != recipe.baseServings {
                Text("Ingredients scaled from \(recipe.baseServings) → \(servings) 🪄")
                    .font(.chow(13, .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .transition(.opacity)
            }

            Spacer()

            ChowPrimaryButton(title: "Add to Plan", leadingEmoji: "✨") {
                onPick(recipe, servings)
            }
        }
        .padding(24)
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(Theme.warmGlow)
                .clipShape(Circle())
                .shadow(color: Theme.coral.opacity(0.35), radius: 8, y: 4)
        }
        .buttonStyle(.pressable(scale: 0.88))
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("📖").font(.system(size: 60))
            Text("No recipes yet!")
                .font(.chow(22, .heavy))
                .foregroundStyle(Theme.ink)
            Text("Add some recipes in the Recipes tab first, then come back to plan your week.")
                .font(.chow(15, .medium))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

/// Reusable recipe thumbnail showing a remote image or emoji fallback.
struct RecipeThumbnail: View {
    let recipe: Recipe
    var size: CGFloat = 56

    var body: some View {
        if let urlString = recipe.imageURL, let url = URL(string: urlString) {
            Color.white
                .frame(width: size, height: size)
                .overlay {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                    } placeholder: {
                        ZStack {
                            Theme.peach.opacity(0.3)
                            Text(recipe.emoji).font(.system(size: size * 0.45))
                        }
                    }
                }
                .clipShape(.rect(cornerRadius: size * 0.26))
        } else {
            RoundedRectangle(cornerRadius: size * 0.26)
                .fill(Theme.peach.opacity(0.35))
                .frame(width: size, height: size)
                .overlay { Text(recipe.emoji).font(.system(size: size * 0.5)) }
        }
    }
}

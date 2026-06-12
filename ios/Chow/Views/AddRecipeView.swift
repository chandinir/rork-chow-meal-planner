//
//  AddRecipeView.swift
//  Chow
//
//  Add a recipe by pasting a URL (auto-scraped) or building one manually.
//

import SwiftUI

struct AddRecipeView: View {
    let onSave: (Recipe) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var urlString = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var scraped: ScrapedRecipe?

    // Editable fields after scrape / for manual entry.
    @State private var name = ""
    @State private var servings = 2
    @State private var imageURL: String?
    @State private var sourceSite = ""
    @State private var ingredientText = ""

    private let emojiChoices = ["🍝", "🥗", "🍲", "🍗", "🥞", "🌮", "🍜", "🥘", "🍛", "🥪", "🍳", "🌶️"]
    @State private var chosenEmoji = "🍽️"
    @State private var manualMode = false

    private var hasDraft: Bool { scraped != nil || manualMode }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        urlCard
                        if let errorMessage {
                            errorBanner(errorMessage)
                        }
                        if hasDraft {
                            draftEditor
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.inkSoft)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if hasDraft {
                        Button("Save") { save() }
                            .font(.chow(16, .bold))
                            .foregroundStyle(name.isEmpty ? Theme.inkSoft : Theme.coral)
                            .disabled(name.isEmpty)
                    }
                }
            }
        }
    }

    // MARK: - URL card

    private var urlCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Paste a recipe link 🔗")
                .font(.chow(18, .heavy))
                .foregroundStyle(Theme.ink)
            HStack {
                Image(systemName: "link")
                    .foregroundStyle(Theme.inkSoft)
                TextField("https://...", text: $urlString)
                    .font(.chow(15, .medium))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .submitLabel(.go)
                    .onSubmit(scrape)
            }
            .padding(14)
            .background(Theme.cream)
            .clipShape(.rect(cornerRadius: 14))

            Button(action: scrape) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView().tint(.white)
                        Text("Grabbing recipe...")
                    } else {
                        Text("✨")
                        Text("Auto-fill from link")
                    }
                }
                .font(.chow(16, .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.sunset)
                .clipShape(.rect(cornerRadius: 16))
            }
            .buttonStyle(.pressable)
            .opacity(urlString.trimmingCharacters(in: .whitespaces).isEmpty || isLoading ? 0.5 : 1)
            .disabled(urlString.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)

            Button {
                Haptics.tap()
                startManual()
            } label: {
                Text("…or add one manually")
                    .font(.chow(14, .semibold))
                    .foregroundStyle(Theme.coral)
            }
            .frame(maxWidth: .infinity)
        }
        .chowCard()
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Text("😕").font(.system(size: 24))
            Text(message)
                .font(.chow(14, .medium))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.pink.opacity(0.18))
        .clipShape(.rect(cornerRadius: 16))
    }

    // MARK: - Draft editor

    private var draftEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Thumbnail preview
            Color.white
                .frame(height: 160)
                .overlay {
                    if let imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                        } placeholder: {
                            ZStack { Theme.peach.opacity(0.3); Text(chosenEmoji).font(.system(size: 50)) }
                        }
                    } else {
                        ZStack {
                            LinearGradient(colors: [Theme.golden.opacity(0.4), Theme.peach.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                            Text(chosenEmoji).font(.system(size: 60))
                        }
                    }
                }
                .clipShape(.rect(cornerRadius: 18))

            field(title: "Recipe name") {
                TextField("Tasty dish", text: $name)
                    .font(.chow(17, .bold))
            }

            // Emoji picker (used as fallback when no thumbnail)
            VStack(alignment: .leading, spacing: 8) {
                Text("Pick an emoji")
                    .font(.chow(13, .bold))
                    .foregroundStyle(Theme.inkSoft)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(emojiChoices, id: \.self) { emoji in
                            Button {
                                Haptics.tap()
                                chosenEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 46, height: 46)
                                    .background(chosenEmoji == emoji ? Theme.golden.opacity(0.3) : Theme.cream)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(chosenEmoji == emoji ? Theme.coral : .clear, lineWidth: 2))
                            }
                            .buttonStyle(.pressable(scale: 0.85))
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }

            HStack {
                Text("Base servings")
                    .font(.chow(15, .bold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Stepper(value: $servings, in: 1...20) {
                    Text("\(servings)")
                        .font(.chow(17, .heavy))
                        .foregroundStyle(Theme.coral)
                }
                .fixedSize()
            }

            field(title: "Ingredients (one per line)") {
                TextEditor(text: $ingredientText)
                    .font(.chow(15, .medium))
                    .frame(minHeight: 140)
                    .scrollContentBackground(.hidden)
            }
            Text("e.g. \"2 cups flour\" — Chow parses amounts & sorts them into aisles for you.")
                .font(.chow(12, .medium))
                .foregroundStyle(Theme.inkSoft)
        }
        .chowCard()
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.chow(13, .bold))
                .foregroundStyle(Theme.inkSoft)
            content()
                .padding(12)
                .background(Theme.cream)
                .clipShape(.rect(cornerRadius: 14))
        }
    }

    // MARK: - Actions

    private func scrape() {
        let trimmed = urlString.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !isLoading else { return }
        Haptics.tap()
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await RecipeScraper.scrape(urlString: trimmed)
                await MainActor.run {
                    applyScraped(result)
                    isLoading = false
                    Haptics.success()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = (error as? RecipeScrapeError)?.errorDescription ?? "Something went wrong. Try a different link."
                    Haptics.warning()
                }
            }
        }
    }

    private func applyScraped(_ result: ScrapedRecipe) {
        scraped = result
        if result.imageURL == nil { chosenEmoji = emojiChoices.first ?? "🍽️" }
        name = result.name
        servings = result.servings
        imageURL = result.imageURL
        sourceSite = result.sourceSite
        ingredientText = result.ingredients.map { ing in
            var parts: [String] = []
            if let q = ing.quantity { parts.append(Ingredient.formatNumber(q)) }
            if let u = ing.unit { parts.append(u) }
            parts.append(ing.name)
            return parts.joined(separator: " ")
        }.joined(separator: "\n")
    }

    private func startManual() {
        scraped = nil
        errorMessage = nil
        chosenEmoji = emojiChoices.first ?? "🍽️"
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            manualMode = true
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let ingredients: [Ingredient] = ingredientText
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { line in
                let parsed = IngredientParser.parse(line)
                return Ingredient(name: parsed.name, quantity: parsed.quantity, unit: parsed.unit)
            }

        let recipe = Recipe(
            name: trimmedName,
            sourceSite: sourceSite,
            sourceURL: urlString.isEmpty ? nil : urlString,
            imageURL: imageURL,
            emoji: chosenEmoji,
            baseServings: servings,
            ingredients: ingredients
        )
        onSave(recipe)
        dismiss()
    }
}

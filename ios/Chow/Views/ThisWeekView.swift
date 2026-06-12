//
//  ThisWeekView.swift
//  Chow
//
//  The weekly meal planner — Monday through Sunday with lunch & dinner slots.
//

import SwiftUI
import SwiftData

struct ThisWeekView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plannedMeals: [PlannedMeal]
    @Query(sort: \Recipe.dateAdded, order: .reverse) private var recipes: [Recipe]

    @State private var slotToFill: SlotFillContext?
    @State private var confettiTrigger = 0
    @State private var showCelebration = false
    @State private var showClearConfirmation = false

    private let totalSlots = 14

    private var plannedCount: Int {
        plannedMeals.filter { $0.recipe != nil }.count
    }

    private var progress: Double {
        Double(plannedCount) / Double(totalSlots)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    progressCard

                    ForEach(Weekday.allCases) { day in
                        DayCard(
                            day: day,
                            lunch: meal(for: day, type: .lunch),
                            dinner: meal(for: day, type: .dinner),
                            onTapSlot: { type in
                                Haptics.tap()
                                let existing = meal(for: day, type: type)
                                slotToFill = SlotFillContext(
                                    day: day,
                                    meal: type,
                                    existingRecipe: existing?.recipe,
                                    existingServings: existing?.servings ?? 2
                                )
                            },
                            onClearSlot: { type in clearSlot(day: day, type: type) }
                        )
                    }

                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }

            ConfettiView(trigger: confettiTrigger)
                .ignoresSafeArea()

            if showCelebration {
                celebrationOverlay
            }
        }
        .alert("Clear All Meals?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear Everything", role: .destructive) { clearAll() }
        } message: {
            Text("This removes every planned meal and resets the grocery list. Your saved recipes and manually-added items will be kept safe.")
        }
        .sheet(item: $slotToFill) { context in
            RecipePickerView(
                recipes: recipes,
                initialRecipe: context.existingRecipe,
                initialServings: context.existingServings
            ) { recipe, servings in
                assign(recipe: recipe, servings: servings, day: context.day, type: context.meal)
                slotToFill = nil
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This Week")
                        .font(.chow(34, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(greeting)
                        .font(.chow(15, .semibold))
                        .foregroundStyle(Theme.inkSoft)
                }
                Spacer()
                if plannedCount > 0 {
                    Button {
                        Haptics.tap()
                        showClearConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.inkSoft)
                            .frame(width: 40, height: 40)
                            .background(Theme.golden.opacity(0.2), in: Circle())
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.9))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(progressMessage)
                    .font(.chow(18, .bold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text("\(plannedCount)/\(totalSlots)")
                    .font(.chow(18, .heavy))
                    .foregroundStyle(Theme.coral)
                    .contentTransition(.numericText(value: Double(plannedCount)))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.golden.opacity(0.25))
                    Capsule()
                        .fill(Theme.sunset)
                        .frame(width: max(14, geo.size.width * progress))
                        .overlay(alignment: .trailing) {
                            Text("🍅")
                                .font(.system(size: 18))
                                .offset(x: 6)
                                .opacity(progress > 0.02 ? 1 : 0)
                        }
                }
            }
            .frame(height: 16)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
        }
        .chowCard()
    }

    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.15).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("🎉")
                    .font(.system(size: 70))
                    .phaseAnimator([false, true], trigger: showCelebration) { content, phase in
                        content.scaleEffect(phase ? 1.0 : 0.4).rotationEffect(.degrees(phase ? 0 : -30))
                    } animation: { _ in .spring(response: 0.5, dampingFraction: 0.45) }
                Text("Every meal planned!")
                    .font(.chow(24, .heavy))
                    .foregroundStyle(Theme.ink)
                Text("Your grocery list is ready in the 🛒 tab.")
                    .font(.chow(15, .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .padding(28)
            .frame(maxWidth: 300)
            .chowCard()
            .transition(.scale(scale: 0.7).combined(with: .opacity))
        }
        .transition(.opacity)
        .onTapGesture { dismissCelebration() }
    }

    // MARK: - Helpers

    private var greeting: String {
        if plannedCount == 0 { return "Let's plan something tasty! 🌟" }
        if plannedCount >= totalSlots { return "Every meal planned — you legend! 👑" }
        return "Looking delicious so far ✨"
    }

    private var progressMessage: String {
        switch plannedCount {
        case 0: "No meals planned yet"
        case totalSlots: "Full week planned!"
        default: "\(plannedCount) of \(totalSlots) meals planned!"
        }
    }

    private func meal(for day: Weekday, type: MealType) -> PlannedMeal? {
        plannedMeals.first { $0.dayIndex == day.rawValue && $0.mealType == type }
    }

    private func assign(recipe: Recipe, servings: Int, day: Weekday, type: MealType) {
        if let existing = meal(for: day, type: type) {
            existing.recipe = recipe
            existing.servings = servings
        } else {
            let meal = PlannedMeal(dayIndex: day.rawValue, mealType: type, servings: servings, recipe: recipe)
            modelContext.insert(meal)
        }
        try? modelContext.save()
        Haptics.success()

        buildGroceryList()

        if plannedCount >= totalSlots {
            celebrate()
        }
    }

    private func clearSlot(day: Weekday, type: MealType) {
        if let existing = meal(for: day, type: type) {
            modelContext.delete(existing)
            try? modelContext.save()
            Haptics.rigid()
            buildGroceryList()
        }
    }

    private func buildGroceryList() {
        // Preserve manual items and previously checked state.
        let existing = (try? modelContext.fetch(FetchDescriptor<GroceryItem>())) ?? []
        var checkedKeys = Set<String>()
        for item in existing {
            if item.isChecked {
                checkedKeys.insert("\(item.name.lowercased())|\(item.unit?.lowercased() ?? "")")
            }
            if !item.isManual {
                modelContext.delete(item)
            }
        }

        let mealInputs: [(ingredients: [Ingredient], scale: Double)] = plannedMeals.compactMap { meal in
            guard let recipe = meal.recipe else { return nil }
            let scale = Double(meal.servings) / Double(max(1, recipe.baseServings))
            return (recipe.ingredients, scale)
        }

        let aggregated = GroceryListBuilder.build(from: mealInputs)
        for (index, item) in aggregated.enumerated() {
            let key = "\(item.name.lowercased())|\(item.unit?.lowercased() ?? "")"
            let grocery = GroceryItem(
                name: item.name,
                quantity: item.quantity,
                unit: item.unit,
                category: item.category,
                isChecked: checkedKeys.contains(key),
                isManual: false
            )
            grocery.sortIndex = index
            modelContext.insert(grocery)
        }
        try? modelContext.save()
    }

    private func celebrate() {
        confettiTrigger += 1
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showCelebration = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            dismissCelebration()
        }
    }

    private func clearAll() {
        for meal in plannedMeals {
            modelContext.delete(meal)
        }

        let groceries = (try? modelContext.fetch(FetchDescriptor<GroceryItem>())) ?? []
        for item in groceries where !item.isManual {
            modelContext.delete(item)
        }

        try? modelContext.save()
        Haptics.warning()
    }

    private func dismissCelebration() {
        withAnimation(.smooth(duration: 0.3)) {
            showCelebration = false
        }
    }
}

/// Context for opening the recipe picker — may include an existing meal for editing.
private struct SlotFillContext: Identifiable {
    let day: Weekday
    let meal: MealType
    var existingRecipe: Recipe?
    var existingServings: Int
    var id: String { "\(day.rawValue)-\(meal.rawValue)" }
}

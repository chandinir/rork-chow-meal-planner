//
//  GroceryListView.swift
//  Chow
//
//  The grocery list — categorized, checkable, with a full-list celebration.
//

import SwiftUI
import SwiftData

struct GroceryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroceryItem.sortIndex) private var items: [GroceryItem]

    @State private var showAddItem = false
    @State private var newItemName = ""
    @State private var celebrationTrigger = 0
    @State private var showAllDoneBanner = false

    private var checkedCount: Int { items.filter(\.isChecked).count }
    private var allChecked: Bool { !items.isEmpty && checkedCount == items.count }

    private var groupedCategories: [GroceryCategory] {
        let present = Set(items.map(\.category))
        return GroceryCategory.allCases
            .filter { present.contains($0) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ZStack {
            if items.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 18) {
                        header
                        progressPill

                        ForEach(groupedCategories) { category in
                            CategorySection(
                                category: category,
                                items: items.filter { $0.category == category },
                                onToggle: toggle
                            )
                        }

                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                }
            }

            ConfettiView(trigger: celebrationTrigger, foodMode: true)
                .ignoresSafeArea()

            if showAllDoneBanner {
                allDoneBanner
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if !items.isEmpty {
                addButton
                    .padding(.trailing, 24)
                    .padding(.bottom, 96)
            }
        }
        .sheet(isPresented: $showAddItem) {
            addItemSheet
                .presentationDetents([.height(240)])
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Grocery List")
                    .font(.chow(34, .heavy))
                    .foregroundStyle(Theme.ink)
                Text(allChecked ? "All done — go you! 🎊" : "\(items.count - checkedCount) left to grab")
                    .font(.chow(15, .semibold))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer()
            Text("🛒").font(.system(size: 44)).rotationEffect(.degrees(6))
        }
        .padding(.top, 6)
    }

    private var progressPill: some View {
        HStack(spacing: 12) {
            Text("\(checkedCount) of \(items.count) checked")
                .font(.chow(15, .bold))
                .foregroundStyle(Theme.ink)
            Spacer()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.golden.opacity(0.25))
                    Capsule()
                        .fill(Theme.sunset)
                        .frame(width: max(8, geo.size.width * progress))
                }
            }
            .frame(width: 120, height: 12)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
        }
        .chowCard(padding: 14)
    }

    private var progress: Double {
        items.isEmpty ? 0 : Double(checkedCount) / Double(items.count)
    }

    private var addButton: some View {
        Button {
            Haptics.tap()
            newItemName = ""
            showAddItem = true
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

    private var addItemSheet: some View {
        VStack(spacing: 18) {
            Text("Add an item 🛍️")
                .font(.chow(22, .heavy))
                .foregroundStyle(Theme.ink)
                .padding(.top, 8)
            TextField("e.g. paper towels", text: $newItemName)
                .font(.chow(17, .semibold))
                .padding(16)
                .background(Theme.cream)
                .clipShape(.rect(cornerRadius: 16))
                .submitLabel(.done)
                .onSubmit(addManualItem)
            ChowPrimaryButton(title: "Add to List", leadingEmoji: "➕") {
                addManualItem()
            }
            .opacity(newItemName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(22)
    }

    private var allDoneBanner: some View {
        VStack(spacing: 14) {
            PhaseAnimator([0, 1, 2], trigger: showAllDoneBanner) { phase in
                Text("💃")
                    .font(.system(size: 72))
                    .rotationEffect(.degrees(phase == 1 ? 14 : phase == 2 ? -14 : 0))
                    .scaleEffect(phase == 0 ? 0.5 : 1.0)
            } animation: { _ in .spring(response: 0.4, dampingFraction: 0.45) }
            Text("Shopping complete!")
                .font(.chow(24, .heavy))
                .foregroundStyle(Theme.ink)
            Text("You crushed your whole list. Time to cook something amazing! 🍳")
                .font(.chow(15, .medium))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: 300)
        .chowCard()
        .transition(.scale(scale: 0.7).combined(with: .opacity))
        .onTapGesture {
            withAnimation(.smooth) { showAllDoneBanner = false }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🧺").font(.system(size: 72))
            Text("Your basket is empty")
                .font(.chow(24, .heavy))
                .foregroundStyle(Theme.ink)
            Text("Plan some meals in the 📅 This Week tab, then tap \"Build My Grocery List!\" to fill this up.")
                .font(.chow(15, .medium))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                Haptics.tap()
                newItemName = ""
                showAddItem = true
            } label: {
                Text("Or add an item manually")
                    .font(.chow(15, .bold))
                    .foregroundStyle(Theme.coral)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Theme.golden.opacity(0.2))
                    .clipShape(Capsule())
            }
            .buttonStyle(.pressable)
            .padding(.top, 4)
        }
    }

    // MARK: - Actions

    private func toggle(_ item: GroceryItem) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            item.isChecked.toggle()
        }
        if item.isChecked {
            Haptics.medium()
        } else {
            Haptics.tap()
        }
        try? modelContext.save()

        if allChecked {
            celebrateAllDone()
        }
    }

    private func addManualItem() {
        let trimmed = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = GroceryItem(
            name: trimmed,
            category: GroceryCategory.classify(trimmed),
            isManual: true
        )
        item.sortIndex = (items.map(\.sortIndex).max() ?? 0) + 1
        modelContext.insert(item)
        try? modelContext.save()
        Haptics.success()
        newItemName = ""
        showAddItem = false
    }

    private func celebrateAllDone() {
        celebrationTrigger += 1
        Haptics.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showAllDoneBanner = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.smooth(duration: 0.3)) { showAllDoneBanner = false }
        }
    }
}

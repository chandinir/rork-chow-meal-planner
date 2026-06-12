//
//  RootView.swift
//  Chow
//
//  Custom bouncy tab bar shell tying the three main tabs together.
//

import SwiftUI

enum ChowTab: Int, CaseIterable, Identifiable {
    case week, grocery, recipes

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .week: "This Week"
        case .grocery: "Groceries"
        case .recipes: "Recipes"
        }
    }

    var emoji: String {
        switch self {
        case .week: "📅"
        case .grocery: "🛒"
        case .recipes: "📖"
        }
    }
}

struct RootView: View {
    @State private var selectedTab: ChowTab = .week

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .week:
                    ThisWeekView()
                case .grocery:
                    GroceryListView()
                case .recipes:
                    RecipesView()
                }
            }
            .transition(.asymmetric(
                insertion: .scale(scale: 0.94).combined(with: .opacity),
                removal: .opacity
            ))

            ChowTabBar(selectedTab: $selectedTab)
        }
    }
}

private struct ChowTabBar: View {
    @Binding var selectedTab: ChowTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChowTab.allCases) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    guard selectedTab != tab else { return }
                    Haptics.tap()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.62)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            Capsule(style: .continuous)
                .fill(.white)
                .shadow(color: Theme.cardShadow, radius: 16, x: 0, y: 6)
        )
        .padding(.horizontal, 28)
        .padding(.bottom, 6)
    }
}

private struct TabBarButton: View {
    let tab: ChowTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(tab.emoji)
                    .font(.system(size: 22))
                    .scaleEffect(isSelected ? 1.25 : 1.0)
                    .rotationEffect(.degrees(isSelected ? -8 : 0))
                Text(tab.title)
                    .font(.chow(11, isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? Theme.coral : Theme.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Theme.golden.opacity(0.22) : .clear)
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.55), value: isSelected)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

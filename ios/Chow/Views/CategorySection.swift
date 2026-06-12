//
//  CategorySection.swift
//  Chow
//
//  A grocery category group with a fun emoji header and poppy checkboxes.
//

import SwiftUI

struct CategorySection: View {
    let category: GroceryCategory
    let items: [GroceryItem]
    let onToggle: (GroceryItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(category.emoji).font(.system(size: 22))
                Text(category.title)
                    .font(.chow(19, .heavy))
                    .foregroundStyle(category.tint)
                Spacer()
                Text("\(items.filter(\.isChecked).count)/\(items.count)")
                    .font(.chow(13, .bold))
                    .foregroundStyle(Theme.inkSoft)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 8) {
                ForEach(items) { item in
                    GroceryRow(item: item) { onToggle(item) }
                }
            }
        }
        .chowCard(padding: 14)
    }
}

private struct GroceryRow: View {
    let item: GroceryItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                PopCheckbox(isChecked: item.isChecked, tint: item.category.tint)

                Text(item.displayString)
                    .font(.chow(16, .semibold))
                    .foregroundStyle(item.isChecked ? Theme.inkSoft.opacity(0.6) : Theme.ink)
                    .strikethrough(item.isChecked, color: Theme.inkSoft.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                if item.isManual {
                    Text("✏️").font(.system(size: 13)).opacity(0.6)
                }
            }
            .opacity(item.isChecked ? 0.65 : 1)
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressable(scale: 0.98))
    }
}

/// A chunky checkbox with a satisfying pop + checkmark animation.
struct PopCheckbox: View {
    let isChecked: Bool
    var tint: Color = Theme.coral

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .strokeBorder(isChecked ? tint : Theme.inkSoft.opacity(0.35), lineWidth: 2.5)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(isChecked ? tint : Color.clear)
                )
                .frame(width: 28, height: 28)

            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(.white)
                .scaleEffect(isChecked ? 1 : 0.1)
                .opacity(isChecked ? 1 : 0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.45), value: isChecked)
        .phaseAnimator([1.0, 1.35, 1.0], trigger: isChecked) { content, scale in
            content.scaleEffect(isChecked ? scale : 1.0)
        } animation: { _ in
            .spring(response: 0.22, dampingFraction: 0.5)
        }
    }
}

//
//  DayCard.swift
//  Chow
//
//  A single day in the weekly planner with lunch & dinner slots.
//

import SwiftUI

struct DayCard: View {
    let day: Weekday
    let lunch: PlannedMeal?
    let dinner: PlannedMeal?
    let onTapSlot: (MealType) -> Void
    let onClearSlot: (MealType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(day.emoji).font(.system(size: 20))
                Text(day.fullName)
                    .font(.chow(20, .heavy))
                    .foregroundStyle(Theme.ink)
                Spacer()
            }

            MealSlotRow(
                type: .lunch,
                meal: lunch,
                onTap: { onTapSlot(.lunch) },
                onClear: { onClearSlot(.lunch) }
            )
            MealSlotRow(
                type: .dinner,
                meal: dinner,
                onTap: { onTapSlot(.dinner) },
                onClear: { onClearSlot(.dinner) }
            )
        }
        .chowCard()
    }
}

private struct MealSlotRow: View {
    let type: MealType
    let meal: PlannedMeal?
    let onTap: () -> Void
    let onClear: () -> Void

    @State private var isPressed = false

    private var isFilled: Bool { meal?.recipe != nil }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                thumbnail

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(type.emoji) \(type.title)")
                        .font(.chow(12, .bold))
                        .foregroundStyle(type == .lunch ? Theme.tangerine : Theme.coral)
                    if let recipe = meal?.recipe {
                        Text(recipe.name)
                            .font(.chow(16, .bold))
                            .foregroundStyle(Theme.ink)
                            .lineLimit(1)
                        Text("Serves \(meal?.servings ?? recipe.baseServings)")
                            .font(.chow(12, .medium))
                            .foregroundStyle(Theme.inkSoft)
                    } else {
                        Text("Tap to add a recipe")
                            .font(.chow(15, .semibold))
                            .foregroundStyle(Theme.inkSoft.opacity(0.7))
                    }
                }
                Spacer()

                if isFilled {
                    Button {
                        Haptics.tap()
                        onClear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.inkSoft.opacity(0.4))
                    }
                    .buttonStyle(.pressable)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Theme.golden)
                }
            }
            .padding(12)
            .background(isFilled ? Theme.cream : Theme.golden.opacity(0.10))
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isFilled ? Color.clear : Theme.golden.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: isFilled ? [] : [6, 5]))
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(color: isPressed ? Theme.cardShadow : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isPressed = pressing }
        }, perform: {})
    }

    @ViewBuilder
    private var thumbnail: some View {
        let size: CGFloat = 52
        if let recipe = meal?.recipe {
            if let urlString = recipe.imageURL, let url = URL(string: urlString) {
                Color.white
                    .frame(width: size, height: size)
                    .overlay {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                        } placeholder: {
                            Text(recipe.emoji).font(.system(size: 26))
                        }
                    }
                    .clipShape(.rect(cornerRadius: 14))
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.peach.opacity(0.4))
                    .frame(width: size, height: size)
                    .overlay { Text(recipe.emoji).font(.system(size: 28)) }
            }
        } else {
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.golden.opacity(0.18))
                .frame(width: size, height: size)
                .overlay {
                    Text(type.emoji).font(.system(size: 24)).opacity(0.5)
                }
        }
    }
}

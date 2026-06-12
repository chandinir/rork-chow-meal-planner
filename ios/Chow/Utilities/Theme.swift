//
//  Theme.swift
//  Chow
//
//  Warm sunset palette + reusable styling for a playful cooking companion.
//

import SwiftUI

/// Central design tokens for Chow's warm, sunset-inspired look.
enum Theme {
    // Core sunset palette
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let peach = Color(red: 1.0, green: 0.71, blue: 0.55)
    static let golden = Color(red: 1.0, green: 0.81, blue: 0.36)
    static let tangerine = Color(red: 1.0, green: 0.58, blue: 0.33)
    static let pink = Color(red: 1.0, green: 0.55, blue: 0.66)

    // Surfaces & text
    static let cream = Color(red: 1.0, green: 0.97, blue: 0.92)
    static let card = Color.white
    static let ink = Color(red: 0.32, green: 0.20, blue: 0.17)
    static let inkSoft = Color(red: 0.52, green: 0.38, blue: 0.34)

    /// Soft sunset wash used for the app background.
    static var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.95, blue: 0.86),
                Color(red: 1.0, green: 0.90, blue: 0.82),
                Color(red: 1.0, green: 0.86, blue: 0.83),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Bold sunset gradient for hero buttons and accents.
    static var sunset: LinearGradient {
        LinearGradient(
            colors: [golden, tangerine, coral],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var warmGlow: LinearGradient {
        LinearGradient(
            colors: [pink, coral],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Soft drop shadow for cards.
    static let cardShadow = Color(red: 0.9, green: 0.5, blue: 0.35).opacity(0.22)
}

extension Font {
    /// Chunky friendly rounded type at a given size/weight.
    static func chow(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// A soft rounded card surface with a subtle lift shadow.
struct ChowCard: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 26
    var fill: Color = Theme.card

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(fill)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .shadow(color: Theme.cardShadow, radius: 14, x: 0, y: 8)
    }
}

extension View {
    func chowCard(padding: CGFloat = 16, cornerRadius: CGFloat = 26, fill: Color = Theme.card) -> some View {
        modifier(ChowCard(padding: padding, cornerRadius: cornerRadius, fill: fill))
    }
}

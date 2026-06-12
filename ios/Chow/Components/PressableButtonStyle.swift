//
//  PressableButtonStyle.swift
//  Chow
//
//  A bouncy button style with press scale + haptic feedback.
//

import SwiftUI

/// Adds a springy scale-down and light haptic when pressed.
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.93

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.5), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Haptics.soft() }
            }
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
    static func pressable(scale: CGFloat) -> PressableButtonStyle { PressableButtonStyle(scale: scale) }
}

/// A big sunset call-to-action button.
struct ChowPrimaryButton: View {
    let title: String
    var systemImageFallback: String?
    var leadingEmoji: String?
    var gradient: LinearGradient = Theme.sunset
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let leadingEmoji {
                    Text(leadingEmoji).font(.chow(22))
                }
                Text(title)
                    .font(.chow(20, .heavy))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(gradient)
            .clipShape(.rect(cornerRadius: 24))
            .shadow(color: Theme.coral.opacity(0.4), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.pressable)
    }
}

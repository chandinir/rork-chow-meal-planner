//
//  ConfettiView.swift
//  Chow
//
//  A burst of confetti / food emojis for celebratory moments.
//

import SwiftUI

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let symbol: String
    let startX: CGFloat
    let xDrift: CGFloat
    let delay: Double
    let rotation: Double
    let scale: CGFloat
    let isEmoji: Bool
    let color: Color
}

/// A full-screen celebratory confetti burst. Pass a `trigger` value that changes to fire it.
struct ConfettiView: View {
    var trigger: Int
    /// When true, uses food emojis; otherwise colorful confetti shapes.
    var foodMode: Bool = false

    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    private let foodEmojis = ["🥕", "🍅", "🥦", "🧀", "🍞", "🍋", "🌶️", "🥑", "🍝", "🥗", "🍗", "🥞"]
    private let confettiColors = [Theme.coral, Theme.golden, Theme.pink, Theme.tangerine, Theme.peach]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Group {
                        if piece.isEmoji {
                            Text(piece.symbol)
                                .font(.system(size: 30 * piece.scale))
                        } else {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(piece.color)
                                .frame(width: 12 * piece.scale, height: 16 * piece.scale)
                        }
                    }
                    .position(
                        x: geo.size.width * piece.startX,
                        y: animate ? geo.size.height + 60 : -60
                    )
                    .offset(x: animate ? piece.xDrift : 0)
                    .rotationEffect(.degrees(animate ? piece.rotation : 0))
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeIn(duration: 2.2).delay(piece.delay),
                        value: animate
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in fire() }
    }

    private func fire() {
        pieces = (0..<40).map { _ in
            ConfettiPiece(
                symbol: foodEmojis.randomElement() ?? "🎉",
                startX: CGFloat.random(in: 0.05...0.95),
                xDrift: CGFloat.random(in: -60...60),
                delay: Double.random(in: 0...0.35),
                rotation: Double.random(in: 180...720),
                scale: CGFloat.random(in: 0.7...1.3),
                isEmoji: foodMode ? true : Bool.random(),
                color: confettiColors.randomElement() ?? Theme.coral
            )
        }
        animate = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            animate = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            pieces = []
        }
    }
}

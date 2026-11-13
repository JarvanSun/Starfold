//
//  Shimmer.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension View {
    public func shimmering() -> some View {
        modifier(Shimmer())
    }
}

private struct Shimmer: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    highlight
                        .mask(content)
                        .allowsHitTesting(false)
                }
            }
            .onAppear { sweep() }
    }

    private var highlight: some View {
        let highlightOpacity = 0.10
        let highlightWidthFraction: CGFloat = 0.6
        let travelFraction: CGFloat = 1.4

        return GeometryReader { proxy in
            LinearGradient(
                colors: [.clear, .white.opacity(highlightOpacity), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: proxy.size.width * highlightWidthFraction)
            .offset(x: phase * proxy.size.width * travelFraction)
        }
    }

    private func sweep() {
        guard !reduceMotion else { return }

        let sweepAnimation: Animation = .linear(duration: 1.4).repeatForever(autoreverses: false)

        withAnimation(sweepAnimation) {
            phase = 1
        }
    }
}

#if DEBUG
#Preview {
    Color.cardFill
        .frame(width: 240, height: 120)
        .shimmering()
        .padding()
        .background(.black)
}
#endif

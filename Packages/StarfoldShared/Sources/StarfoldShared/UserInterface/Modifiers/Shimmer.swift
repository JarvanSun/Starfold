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
}

private extension Shimmer {
    var highlightOpacity: Double {
        0.10
    }

    var highlightWidthFraction: CGFloat {
        0.6
    }

    var travelFraction: CGFloat {
        1.4
    }

    var sweepAnimation: Animation {
        .linear(duration: 1.4).repeatForever(autoreverses: false)
    }

    var highlight: some View {
        GeometryReader { proxy in
            LinearGradient(
                colors: [.clear, .white.opacity(highlightOpacity), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: proxy.size.width * highlightWidthFraction)
            .offset(x: phase * proxy.size.width * travelFraction)
        }
    }

    func sweep() {
        guard !reduceMotion else { return }

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

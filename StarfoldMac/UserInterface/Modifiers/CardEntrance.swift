//
//  CardEntrance.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

extension View {
    func cardEntrance(index: Int) -> some View {
        modifier(CardEntrance(index: index))
    }
}

private struct CardEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.skipsEntranceAnimations) private var skipsEntranceAnimations
    @Environment(\.dimensions) private var dimensions
    @State private var hasEntered = false

    let index: Int

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isInPlace ? 0 : dimensions.spaceXLarge)
            .scaleEffect(isInPlace ? 1 : startScale)
            .onAppear(perform: enter)
    }
}

private extension CardEntrance {
    var startScale: CGFloat {
        0.96
    }

    var staggerInterval: Double {
        0.08
    }

    var isVisible: Bool {
        hasEntered || skipsEntranceAnimations
    }

    var isInPlace: Bool {
        isVisible || reduceMotion
    }

    var delay: Double {
        reduceMotion ? 0 : Double(index) * staggerInterval
    }

    func enter() {
        withAnimation(.spring(duration: 0.6, bounce: 0.25).delay(delay)) {
            hasEntered = true
        }
    }
}

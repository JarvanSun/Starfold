//
//  StatusDot.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct StatusDot: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions
    @State private var isExpanded = false

    private let color: Color
    private let isPulsing: Bool

    private var showsPulse: Bool {
        isPulsing && !reduceMotion
    }

    public init(color: Color, pulsing: Bool = false) {
        self.color = color
        isPulsing = pulsing
    }

    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: dimensions.statusDotSize, height: dimensions.statusDotSize)
            .background {
                if showsPulse {
                    pulse
                }
            }
            .onAppear { startPulsing() }
            .accessibilityHidden(true)
    }

    private func startPulsing() {
        guard showsPulse else { return }

        let pulseAnimation: Animation = .easeOut(duration: 1.6).repeatForever(autoreverses: false)

        withAnimation(pulseAnimation) {
            isExpanded = true
        }
    }

    private var pulse: some View {
        let pulseOpacity = 0.5
        let pulseStartOpacity = 0.8
        let pulseGrowth: CGFloat = 2.4

        return Circle()
            .fill(color.opacity(pulseOpacity))
            .scaleEffect(isExpanded ? pulseGrowth : 1)
            .opacity(isExpanded ? 0 : pulseStartOpacity)
    }
}

#if DEBUG
#Preview("States") {
    HStack {
        StatusDot(color: .online, pulsing: true)

        StatusDot(color: .online)

        StatusDot(color: .standby)

        StatusDot(color: .attention)
    }
    .padding()
}
#endif

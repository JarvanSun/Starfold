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
}

private extension StatusDot {
    var pulseOpacity: Double {
        0.5
    }

    var pulseStartOpacity: Double {
        0.8
    }

    var pulseGrowth: CGFloat {
        2.4
    }

    var pulseAnimation: Animation {
        .easeOut(duration: 1.6).repeatForever(autoreverses: false)
    }

    var showsPulse: Bool {
        isPulsing && !reduceMotion
    }

    var pulse: some View {
        Circle()
            .fill(color.opacity(pulseOpacity))
            .scaleEffect(isExpanded ? pulseGrowth : 1)
            .opacity(isExpanded ? 0 : pulseStartOpacity)
    }

    func startPulsing() {
        guard showsPulse else { return }

        withAnimation(pulseAnimation) {
            isExpanded = true
        }
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

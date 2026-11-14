//
//  ConnectingIndicator.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct ConnectingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions
    @State private var isSpinning = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.12), lineWidth: dimensions.connectingIndicatorLineWidth)

            arc
        }
        .frame(
            width: dimensions.connectingIndicatorDiameter,
            height: dimensions.connectingIndicatorDiameter
        )
        .onAppear { startSpinning() }
        .accessibilityHidden(true)
    }

    private func startSpinning() {
        guard !reduceMotion else { return }

        withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
            isSpinning = true
        }
    }

    private var arc: some View {
        let arcLength: CGFloat = 0.3

        return Circle()
            .trim(from: 0, to: arcLength)
            .stroke(
                arcGradient,
                style: StrokeStyle(
                    lineWidth: dimensions.connectingIndicatorLineWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .shadow(color: palette.primaryTint.opacity(0.6), radius: dimensions.shadowRadiusSmall)
    }

    private var arcGradient: AngularGradient {
        .init(
            colors: [palette.accent.color.opacity(0), palette.accent.color, palette.primaryTint],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(108)
        )
    }
}

#if DEBUG
#Preview {
    ConnectingIndicator()
        .padding()
        .background(.black)
}
#endif

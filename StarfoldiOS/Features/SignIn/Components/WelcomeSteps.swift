//
//  WelcomeSteps.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct WelcomeSteps: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
            ForEach(WelcomeStep.allCases) { step in
                row(step)
            }
        }
        .background(alignment: .leading) { connector }
        .accessibilityElement(children: .combine)
    }

    private func row(_ step: WelcomeStep) -> some View {
        HStack(spacing: dimensions.spaceLarge) {
            Image(systemName: step.systemImage)
                .font(.title3)
                .frame(
                    width: dimensions.welcomeFeatureSymbolSize,
                    height: dimensions.welcomeFeatureSymbolSize
                )
                .background(palette.nightRaised.color, in: .circle)
                .overlay { Circle().strokeBorder(palette.accent.color.opacity(0.45)) }
                .accessibilityHidden(true)

            Text(step.title)
                .font(.headline)
        }
    }

    private var connector: some View {
        Rectangle()
            .fill(palette.accent.color.opacity(0.35))
            .frame(width: dimensions.highlightLineWidth)
            .padding(.vertical, dimensions.welcomeFeatureSymbolSize / 2)
            .padding(
                .leading,
                (dimensions.welcomeFeatureSymbolSize - dimensions.highlightLineWidth) / 2
            )
    }
}

#if DEBUG
#Preview {
    WelcomeSteps()
        .padding()
        .background(Palette(.nebula).night.color)
        .environment(\.colorScheme, .dark)
}
#endif

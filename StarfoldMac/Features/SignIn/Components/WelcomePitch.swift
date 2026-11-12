//
//  WelcomePitch.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct WelcomePitch: View {
    @Environment(\.dimensions) private var dimensions

    let features: [WelcomeFeature]
    let isInPlace: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
            headline

            VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
                ForEach(features, content: WelcomeFeatureRow.init(feature:))
            }
        }
        .offset(y: isInPlace ? 0 : dimensions.spaceMedium)
    }
}

private extension WelcomePitch {
    var headline: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            AppGlyph(size: dimensions.welcomeGlyphSize)
                .scaleEffect(isInPlace ? 1 : 0.8, anchor: .leading)

            Text("welcome.title")
                .font(.system(size: dimensions.welcomeTitleSize, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)

            Text("welcome.subtitle")
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview {
    WelcomePitch(features: WelcomeFeature.allCases, isInPlace: true)
        .padding()
        .background(Palette(.nebula).night.color)
        .environment(\.colorScheme, .dark)
}
#endif

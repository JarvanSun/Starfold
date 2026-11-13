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

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
            headline

            VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
                ForEach(features) { WelcomeFeatureRow(feature: $0) }
            }
        }
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: dimensions.welcomeSymbolSize))
                .frame(
                    width: dimensions.welcomeSymbolBackgroundSize,
                    height: dimensions.welcomeSymbolBackgroundSize
                )
                .background(.regularMaterial, in: .circle)
                .accessibilityHidden(true)

            Text("welcome.headline")
                .font(.extraLargeTitle)
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
    WelcomePitch(features: WelcomeFeature.allCases)
        .padding()
}
#endif

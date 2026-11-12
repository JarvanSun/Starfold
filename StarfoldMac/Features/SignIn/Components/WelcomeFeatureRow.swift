//
//  WelcomeFeatureRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct WelcomeFeatureRow: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let feature: WelcomeFeature

    var body: some View {
        HStack(spacing: dimensions.spaceMedium) {
            Image(systemName: feature.systemImage)
                .font(.title3)
                .frame(
                    width: dimensions.welcomeFeatureSymbolSize,
                    height: dimensions.welcomeFeatureSymbolSize
                )
                .background(
                    palette.primaryTint.opacity(0.35),
                    in: .rect(cornerRadius: dimensions.cornerRadiusMedium)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: dimensions.spaceXXSmall) {
                Text(feature.title)
                    .font(.headline)

                Text(feature.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        ForEach(WelcomeFeature.allCases, content: WelcomeFeatureRow.init(feature:))
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif

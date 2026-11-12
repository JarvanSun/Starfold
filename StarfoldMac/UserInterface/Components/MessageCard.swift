//
//  MessageCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct MessageCard<Action: View>: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let symbol: String
    let title: String
    let message: String
    @ViewBuilder let action: Action

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Spacer()

            Image(systemName: symbol)
                .font(.system(size: dimensions.messageSymbolSize))
                .foregroundStyle(palette.primaryFill)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            action
                .buttonStyle(.primary)

            Spacer()
        }
        .padding(dimensions.spaceXLarge)
        .frame(width: dimensions.homeCardWidth, height: dimensions.homeCardHeight)
        .cardSurface()
    }
}

#if DEBUG
#Preview {
    MessageCard(
        symbol: "cloud.slash",
        title: String(localized: "library.unavailable.title"),
        message: String(localized: "library.unavailable.message")
    ) {
        Button(String(localized: "library.unavailable.retry"), action: {})
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif

//
//  MessageCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct MessageCard<Action: View>: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let symbol: String
    let title: String
    let message: String
    @ViewBuilder let action: Action

    var body: some View {
        layout
            .padding(dimensions.spaceXLarge)
            .frame(maxWidth: .infinity)
            .frame(height: dimensions.homeCardHeight(forVerticalSizeClass: verticalSizeClass))
            .cardSurface()
    }

    @ViewBuilder
    private var layout: some View {
        switch verticalSizeClass {
        case .compact:
            HStack(spacing: dimensions.spaceXLarge) {
                symbolImage

                VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
                    texts(alignment: .leading, spacing: dimensions.spaceSmall)

                    actionButton
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        default:
            VStack(spacing: dimensions.spaceLarge) {
                Spacer()

                symbolImage

                texts(alignment: .center, spacing: dimensions.spaceLarge)

                actionButton

                Spacer()
            }
        }
    }

    private func texts(alignment: TextAlignment, spacing: CGFloat) -> some View {
        VStack(alignment: stackAlignment(for: alignment), spacing: spacing) {
            Text(title)
                .font(.headline)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func stackAlignment(for alignment: TextAlignment) -> HorizontalAlignment {
        switch alignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    private var symbolImage: some View {
        Image(systemName: symbol)
            .font(.system(size: dimensions.messageSymbolSize))
            .foregroundStyle(palette.primaryFill)
    }

    private var actionButton: some View {
        action
            .buttonStyle(.primary)
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
    .frame(width: 340)
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif

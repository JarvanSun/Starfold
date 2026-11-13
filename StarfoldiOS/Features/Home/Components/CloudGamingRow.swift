//
//  CloudGamingRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct CloudGamingRow: View {
    @Environment(\.dimensions) private var dimensions

    let library: LibraryViewModel
    let onOpen: () -> Void

    var body: some View {
        Button {
            onOpen()
        } label: {
            label
        }
        .buttonStyle(.plain)
        .disabled(!library.canBrowse)
        .accessibilityElement(children: .combine)
    }

    private var label: some View {
        HStack(spacing: dimensions.spaceMedium) {
            covers

            VStack(alignment: .leading, spacing: dimensions.spaceXXSmall) {
                Text("home.cloud.title")
                    .font(.headline)

                status
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .opacity(library.canBrowse ? 1 : 0)
        }
        .padding(dimensions.spaceMedium)
        .cardSurface()
        .contentShape(.rect)
    }

    private var covers: some View {
        let coverLimit = 3

        return HStack(spacing: dimensions.spaceXSmall) {
            ForEach(library.coverArtwork(limit: coverLimit), id: \.self) { url in
                GameArtwork(url: url, aspectRatio: 1)
                    .frame(width: dimensions.cloudRowCoverSize)
            }
        }
        .accessibilityHidden(true)
    }

    private var status: some View {
        HStack(spacing: dimensions.spaceXSmall) {
            StatusDot(color: library.cloudAccess.statusColor, pulsing: false)

            Text(library.cloudAccess.statusText)

            if let subtitle = library.cloudAccess.cardSubtitle(gameCount: library.games.count) {
                Text(verbatim: "·")

                Text(subtitle)
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
}

#if DEBUG
#Preview {
    VStack {
        CloudGamingRow(library: PreviewObjectPool.libraryViewModel()) {}
        CloudGamingRow(library: PreviewObjectPool.libraryViewModel(access: .unavailable)) {}
    }
    .padding()
    .background { SkyBackground() }
    .environment(\.colorScheme, .dark)
}
#endif

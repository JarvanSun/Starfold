//
//  CloudCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CloudCard: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let libraryViewModel: LibraryViewModel

    let onOpen: () -> Void

    var body: some View {
        HomeCard(heading: heading, primaryAction: browseAction) {
            artwork
        } actions: {
            SettingsShortcutButton()
        }
    }

    private var heading: HomeCardHeading {
        .init(
            title: Text("home.cloud.title"),
            subtitle: subtitle,
            status: .init(
                text: Text(libraryViewModel.cloudAccess.statusText),
                color: libraryViewModel.cloudAccess.statusColor,
                isPulsing: false,
                isTextShown: true
            )
        )
    }

    private var subtitle: Text {
        switch libraryViewModel.cloudAccess.cardSubtitle(gameCount: libraryViewModel.games.count) {
        case let subtitle?: Text(subtitle)
        case nil: Text(verbatim: "")
        }
    }

    private var browseAction: HomeCardAction {
        .init(
            title: "home.cloud.browse",
            systemImage: "square.grid.2x2",
            isEnabled: libraryViewModel.canBrowse,
            onPerform: onOpen
        )
    }

    private var artwork: some View {
        let coverLimit = 3

        return CloudCardArt(
            covers: libraryViewModel.coverArtwork(limit: coverLimit),
            access: libraryViewModel.cloudAccess,
            isLoading: libraryViewModel.isLoading
        )
    }
}

#if DEBUG
#Preview {
    HStack {
        CloudCard(libraryViewModel: PreviewObjectPool.libraryViewModel()) {}

        CloudCard(libraryViewModel: PreviewObjectPool.libraryViewModel(state: .loading)) {}

        CloudCard(
            libraryViewModel: PreviewObjectPool.libraryViewModel(games: [], access: .unavailable)
        ) {}
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif

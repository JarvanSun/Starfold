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

    let library: LibraryViewModel
    let onOpen: () -> Void

    var body: some View {
        HomeCard(heading: heading, primaryAction: browseAction) {
            artwork
        } actions: {
            SettingsShortcutButton()
        }
    }
}

private extension CloudCard {
    var coverLimit: Int {
        3
    }

    var heading: HomeCardHeading {
        .init(
            title: Text("home.cloud.title"),
            subtitle: subtitle,
            status: .init(
                text: Text(library.cloudAccess.statusText),
                color: library.cloudAccess.statusColor,
                isPulsing: false,
                isTextShown: true
            )
        )
    }

    var subtitle: Text {
        switch library.cloudAccess.cardSubtitle(gameCount: library.games.count) {
        case let subtitle?: Text(subtitle)
        case nil: Text(verbatim: "")
        }
    }

    var browseAction: HomeCardAction {
        .init(
            title: "home.cloud.browse",
            systemImage: "square.grid.2x2",
            isEnabled: library.canBrowse,
            onPerform: onOpen
        )
    }

    var artwork: some View {
        CloudCardArt(
            covers: library.coverArtwork(limit: coverLimit),
            access: library.cloudAccess,
            isLoading: library.isLoading
        )
    }
}

#if DEBUG
#Preview {
    HStack {
        CloudCard(library: PreviewObjectPool.libraryViewModel()) {}

        CloudCard(library: PreviewObjectPool.libraryViewModel(state: .loading)) {}

        CloudCard(library: PreviewObjectPool.libraryViewModel(games: [], access: .unavailable)) {}
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif

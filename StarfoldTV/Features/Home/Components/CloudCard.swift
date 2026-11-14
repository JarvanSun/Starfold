//
//  CloudCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CloudCard: View {
    let libraryViewModel: LibraryViewModel
    let width: CGFloat

    let onBrowse: () -> Void

    var body: some View {
        let coverLimit = 3

        HomeCard(
            title: Text("home.sources.cloud.title"),
            subtitle: subtitle,
            status: Text(libraryViewModel.cloudAccess.statusText),
            statusColor: libraryViewModel.cloudAccess.statusColor,
            width: width,
            onSelect: onBrowse
        ) {
            CloudCardArt(
                covers: libraryViewModel.coverArtwork(limit: coverLimit),
                access: libraryViewModel.cloudAccess,
                width: width
            )
        }
    }

    private var subtitle: Text {
        switch libraryViewModel.cloudAccess.cardSubtitle(gameCount: libraryViewModel.games.count) {
        case let subtitle?: Text(subtitle)
        case nil: Text(verbatim: "")
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        CloudCard(libraryViewModel: PreviewObjectPool.libraryViewModel(), width: 480, onBrowse: {})

        CloudCard(
            libraryViewModel: PreviewObjectPool.libraryViewModel(access: .freeToPlay),
            width: 480,
            onBrowse: {}
        )

        CloudCard(
            libraryViewModel: PreviewObjectPool.libraryViewModel(games: [], access: .unavailable),
            width: 480,
            onBrowse: {}
        )

        CloudCard(
            libraryViewModel: PreviewObjectPool.libraryViewModel(state: .loading),
            width: 480,
            onBrowse: {}
        )
    }
}
#endif

//
//  CloudCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CloudCard: View {
    let library: LibraryViewModel
    let width: CGFloat

    let onBrowse: () -> Void

    var body: some View {
        let coverLimit = 3

        HomeCard(
            title: Text("home.sources.cloud.title"),
            subtitle: subtitle,
            status: Text(library.cloudAccess.statusText),
            statusColor: library.cloudAccess.statusColor,
            width: width,
            onSelect: onBrowse
        ) {
            CloudCardArt(
                covers: library.coverArtwork(limit: coverLimit),
                access: library.cloudAccess,
                width: width
            )
        }
    }

    private var subtitle: Text {
        switch library.cloudAccess.cardSubtitle(gameCount: library.games.count) {
        case let subtitle?: Text(subtitle)
        case nil: Text(verbatim: "")
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        CloudCard(library: PreviewObjectPool.libraryViewModel(), width: 480, onBrowse: {})

        CloudCard(
            library: PreviewObjectPool.libraryViewModel(access: .freeToPlay),
            width: 480,
            onBrowse: {}
        )

        CloudCard(
            library: PreviewObjectPool.libraryViewModel(games: [], access: .unavailable),
            width: 480,
            onBrowse: {}
        )

        CloudCard(
            library: PreviewObjectPool.libraryViewModel(state: .loading),
            width: 480,
            onBrowse: {}
        )
    }
}
#endif

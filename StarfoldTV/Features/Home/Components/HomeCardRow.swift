//
//  HomeCardRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct HomeCardRow: View {
    @Environment(\.dimensions) private var dimensions

    let home: HomeViewModel
    let library: LibraryViewModel
    let cardWidth: CGFloat
    let onBrowse: () -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: dimensions.spaceXXLarge) {
                switch home.firstConsole {
                case let console?: consoleCard(console)
                case nil: EmptyView()
                }

                CloudCard(library: library, width: cardWidth, onBrowse: onBrowse)

                switch home.consolesContent {
                case .loading: SkeletonCard(width: cardWidth)
                case .failed(let reason): failedMessage(reason)
                case .empty: emptyMessage
                case .consoles: ForEach(home.otherConsoles, content: consoleCard(_:))
                }
            }
            .padding(.vertical, dimensions.spaceMedium)
            .focusSection()
        }
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
    }
}

private extension HomeCardRow {
    var emptyMessage: some View {
        ConsolesMessageCard(
            title: "home.consoles.empty.title",
            message: Text("home.consoles.empty.message"),
            width: cardWidth,
            onRefresh: refreshConsoles
        )
    }

    func failedMessage(_ reason: String) -> some View {
        ConsolesMessageCard(
            title: "home.consoles.failed.title",
            message: Text(reason),
            width: cardWidth,
            onRefresh: refreshConsoles
        )
    }

    func consoleCard(_ console: Console) -> some View {
        ConsoleCard(console: console, home: home, width: cardWidth)
    }

    func refreshConsoles() {
        Task { await home.refreshConsoles() }
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        HomeCardRow(
            home: PreviewObjectPool.homeViewModel(),
            library: PreviewObjectPool.libraryViewModel(),
            cardWidth: 480,
            onBrowse: {}
        )

        HomeCardRow(
            home: PreviewObjectPool.homeViewModel(state: .loading),
            library: PreviewObjectPool.libraryViewModel(state: .loading),
            cardWidth: 480,
            onBrowse: {}
        )

        HomeCardRow(
            home: PreviewObjectPool.homeViewModel(state: PreviewObjectPool.failedLoadState),
            library: PreviewObjectPool.libraryViewModel(),
            cardWidth: 480,
            onBrowse: {}
        )

        HomeCardRow(
            home: PreviewObjectPool.homeViewModel(consoles: []),
            library: PreviewObjectPool.libraryViewModel(),
            cardWidth: 480,
            onBrowse: {}
        )
    }
}
#endif

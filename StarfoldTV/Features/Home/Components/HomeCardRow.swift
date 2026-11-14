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

    let homeViewModel: HomeViewModel
    let libraryViewModel: LibraryViewModel
    let cardWidth: CGFloat

    let onBrowse: () -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: dimensions.spaceXXLarge) {
                switch homeViewModel.firstConsole {
                case let console?: consoleCard(console)
                case nil: EmptyView()
                }

                CloudCard(libraryViewModel: libraryViewModel, width: cardWidth, onBrowse: onBrowse)

                switch homeViewModel.consolesContent {
                case .loading: SkeletonCard(width: cardWidth)
                case .failed(let reason): failedMessage(reason)
                case .empty: emptyMessage
                case .consoles: ForEach(homeViewModel.otherConsoles) { consoleCard($0) }
                }
            }
            .padding(.vertical, dimensions.spaceMedium)
            .focusSection()
        }
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
    }

    private func consoleCard(_ console: Console) -> some View {
        ConsoleCard(console: console, homeViewModel: homeViewModel, width: cardWidth)
    }

    private func failedMessage(_ reason: String) -> some View {
        ConsolesMessageCard(
            title: "home.consoles.failed.title",
            message: Text(reason),
            width: cardWidth,
            onRefresh: { refreshConsoles() }
        )
    }

    private func refreshConsoles() {
        Task { await homeViewModel.refreshConsoles() }
    }

    private var emptyMessage: some View {
        ConsolesMessageCard(
            title: "home.consoles.empty.title",
            message: Text("home.consoles.empty.message"),
            width: cardWidth,
            onRefresh: { refreshConsoles() }
        )
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        HomeCardRow(
            homeViewModel: PreviewObjectPool.homeViewModel(),
            libraryViewModel: PreviewObjectPool.libraryViewModel(),
            cardWidth: 480,
            onBrowse: {}
        )

        HomeCardRow(
            homeViewModel: PreviewObjectPool.homeViewModel(state: .loading),
            libraryViewModel: PreviewObjectPool.libraryViewModel(state: .loading),
            cardWidth: 480,
            onBrowse: {}
        )

        HomeCardRow(
            homeViewModel: PreviewObjectPool.homeViewModel(
                state: PreviewObjectPool.failedLoadState
            ),
            libraryViewModel: PreviewObjectPool.libraryViewModel(),
            cardWidth: 480,
            onBrowse: {}
        )

        HomeCardRow(
            homeViewModel: PreviewObjectPool.homeViewModel(consoles: []),
            libraryViewModel: PreviewObjectPool.libraryViewModel(),
            cardWidth: 480,
            onBrowse: {}
        )
    }
}
#endif

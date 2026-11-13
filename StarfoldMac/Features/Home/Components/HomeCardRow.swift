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

    let onOpenCloudLibrary: () -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: dimensions.spaceXLarge) {
                CloudCard(library: library, onOpen: onOpenCloudLibrary)
                    .cardEntrance(index: 0)

                switch home.consolesContent {
                case .loading: SkeletonCard().cardEntrance(index: 1)
                case .failed(let message): failedCard(message).cardEntrance(index: 1)
                case .empty: NoConsolesCard(onRefresh: { refreshConsoles() }).cardEntrance(index: 1)
                case .consoles: consoleCards
                }
            }
            .padding(.horizontal, dimensions.spaceXXXLarge)
            .padding(.vertical, dimensions.spaceXLarge)
            .frame(minWidth: 0)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .defaultScrollAnchor(.center)
    }

    private func failedCard(_ message: String) -> some View {
        ConsolesFailedCard(message: message, onRetry: { refreshConsoles() })
    }

    private func refreshConsoles() {
        Task { await home.refreshConsoles() }
    }

    private var consoleCards: some View {
        ForEach(Array(home.consoles.enumerated()), id: \.element.id) { index, console in
            ConsoleCard(console: console, home: home)
                .cardEntrance(index: index + 1)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        HomeCardRow(
            home: PreviewObjectPool.homeViewModel(),
            library: PreviewObjectPool.libraryViewModel()
        ) {}

        HomeCardRow(
            home: PreviewObjectPool.homeViewModel(consoles: []),
            library: PreviewObjectPool.libraryViewModel(state: .loading)
        ) {}
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif

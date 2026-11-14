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

    let onOpenCloudLibrary: () -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: dimensions.spaceXLarge) {
                CloudCard(libraryViewModel: libraryViewModel, onOpen: onOpenCloudLibrary)
                    .cardEntrance(index: 0)

                switch homeViewModel.consolesContent {
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
        Task { await homeViewModel.refreshConsoles() }
    }

    private var consoleCards: some View {
        ForEach(Array(homeViewModel.consoles.enumerated()), id: \.element.id) { index, console in
            ConsoleCard(console: console, homeViewModel: homeViewModel)
                .cardEntrance(index: index + 1)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        HomeCardRow(
            homeViewModel: PreviewObjectPool.homeViewModel(),
            libraryViewModel: PreviewObjectPool.libraryViewModel()
        ) {}

        HomeCardRow(
            homeViewModel: PreviewObjectPool.homeViewModel(consoles: []),
            libraryViewModel: PreviewObjectPool.libraryViewModel(state: .loading)
        ) {}
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif

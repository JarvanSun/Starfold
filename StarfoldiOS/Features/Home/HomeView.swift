//
//  HomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct HomeView: View {
    @Environment(\.dimensions) private var dimensions

    let homeViewModel: HomeViewModel
    let libraryViewModel: LibraryViewModel

    let onOpenCloudGaming: () -> Void

    var body: some View {
        let recentGameLimit = 10

        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
                HomeCardRow(homeViewModel: homeViewModel)

                CloudGamingRow(libraryViewModel: libraryViewModel, onOpen: onOpenCloudGaming)
                    .pageMargins()

                if !libraryViewModel.recentGames.isEmpty {
                    RecentGamesRow(
                        games: libraryViewModel.recentGames(limit: recentGameLimit),
                        onPlay: { libraryViewModel.play($0) }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.bottom, dimensions.spaceXLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.smooth(duration: 0.45), value: libraryViewModel.recentGames)
        }
        .scrollIndicators(.hidden)
        .refreshable { await homeViewModel.refreshAccount() }
    }
}

#if DEBUG
@available(iOS 27, *)
#Preview("Home", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        HomeView(
            homeViewModel: PreviewObjectPool.homeViewModel(state: state),
            libraryViewModel: PreviewObjectPool.libraryViewModel(state: state)
        ) {}
        .background { SkyBackground() }
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}

#Preview("No consoles") {
    NavigationStack {
        HomeView(
            homeViewModel: PreviewObjectPool.homeViewModel(consoles: []),
            libraryViewModel: PreviewObjectPool.libraryViewModel(access: .unavailable)
        ) {}
        .background { SkyBackground() }
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif

//
//  HomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import StarfoldShared
import SwiftUI

struct HomeView: View {
    @Environment(\.dimensions) private var dimensions

    let homeViewModel: HomeViewModel
    let libraryViewModel: LibraryViewModel

    let onOpenCloudLibrary: () -> Void

    var body: some View {
        let recentGameLimit = 10

        ScrollView {
            VStack(spacing: dimensions.spaceXXLarge) {
                HomeCardRow(
                    homeViewModel: homeViewModel,
                    libraryViewModel: libraryViewModel,
                    onOpenCloudLibrary: onOpenCloudLibrary
                )

                if !libraryViewModel.recentGames.isEmpty {
                    RecentGamesRow(
                        games: libraryViewModel.recentGames(limit: recentGameLimit),
                        onPlay: { libraryViewModel.play($0) }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.vertical, dimensions.spaceXLarge)
            .frame(maxWidth: .infinity)
            .animation(.smooth(duration: 0.45), value: libraryViewModel.recentGames)
        }
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.center)
        .refreshable { await homeViewModel.refreshAccount() }
    }
}

#if DEBUG
@available(macOS 27, *)
#Preview("Home", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        HomeView(
            homeViewModel: PreviewObjectPool.homeViewModel(state: state),
            libraryViewModel: PreviewObjectPool.libraryViewModel(state: state)
        ) {}
        .background { SkyBackground() }
    }
    .frame(width: 1180, height: 760)
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
    .frame(width: 1180, height: 760)
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif

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

    let home: HomeViewModel
    let library: LibraryViewModel

    var body: some View {
        let recentGameLimit = 10

        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
                HomeCardRow(home: home)

                if !library.recentGames.isEmpty {
                    RecentGamesRow(
                        games: library.recentGames(limit: recentGameLimit),
                        onPlay: { library.play($0) }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.bottom, dimensions.spaceXLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.smooth(duration: 0.45), value: library.recentGames)
        }
        .scrollIndicators(.hidden)
        .refreshable { await home.refreshAccount() }
    }
}

#if DEBUG
@available(iOS 27, *)
#Preview("Home", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        HomeView(
            home: PreviewObjectPool.homeViewModel(state: state),
            library: PreviewObjectPool.libraryViewModel(state: state)
        )
        .background { SkyBackground() }
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}

#Preview("No consoles") {
    NavigationStack {
        HomeView(
            home: PreviewObjectPool.homeViewModel(consoles: []),
            library: PreviewObjectPool.libraryViewModel(access: .unavailable)
        )
        .background { SkyBackground() }
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif

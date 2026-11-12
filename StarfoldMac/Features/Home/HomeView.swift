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

    let home: HomeViewModel
    let library: LibraryViewModel

    let onOpenCloudLibrary: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: dimensions.spaceXXLarge) {
                HomeCardRow(home: home, library: library, onOpenCloudLibrary: onOpenCloudLibrary)

                if !library.recentGames.isEmpty {
                    RecentGamesRow(
                        games: library.recentGames(limit: recentGameLimit),
                        onPlay: { library.play($0) }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.vertical, dimensions.spaceXLarge)
            .frame(maxWidth: .infinity)
            .animation(.smooth(duration: 0.45), value: library.recentGames)
        }
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.center)
        .refreshable { await home.refreshAccount() }
    }
}

private extension HomeView {
    var recentGameLimit: Int {
        10
    }
}

#if DEBUG
@available(macOS 27, *)
#Preview("Home", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        HomeView(
            home: PreviewObjectPool.homeViewModel(state: state),
            library: PreviewObjectPool.libraryViewModel(state: state)
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
            home: PreviewObjectPool.homeViewModel(consoles: []),
            library: PreviewObjectPool.libraryViewModel(access: .unavailable)
        ) {}
        .background { SkyBackground() }
    }
    .frame(width: 1180, height: 760)
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif

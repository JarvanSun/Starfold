//
//  HomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct HomeView: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var homeViewModel: HomeViewModel

    let libraryViewModel: LibraryViewModel

    var body: some View {
        let recentGameLimit = 8

        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                ConsoleShelf(homeViewModel: homeViewModel)

                if !libraryViewModel.recentGames.isEmpty {
                    RecentGamesShelf(
                        games: libraryViewModel.recentGames(limit: recentGameLimit),
                        onPlay: { libraryViewModel.play($0) }
                    )
                }
            }
            .padding(.horizontal, dimensions.spaceXXLarge)
            .padding(.vertical, dimensions.spaceXLarge)
        }
        .refreshable { await homeViewModel.refreshAccount() }
        .alert(
            homeViewModel.powerProblemTitle,
            isPresented: $homeViewModel.isPowerProblemPresented,
            presenting: homeViewModel.powerProblem
        ) { _ in
            Button("app.powerProblem.ok") {}
        } message: { problem in
            Text(problem.message)
        }
    }
}

#if DEBUG
#Preview("Consoles") {
    NavigationStack {
        HomeView(
            homeViewModel: PreviewObjectPool.homeViewModel(),
            libraryViewModel: PreviewObjectPool.libraryViewModel()
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        HomeView(
            homeViewModel: PreviewObjectPool.homeViewModel(state: .loading),
            libraryViewModel: PreviewObjectPool.libraryViewModel()
        )
    }
}

#Preview("No consoles") {
    NavigationStack {
        HomeView(
            homeViewModel: PreviewObjectPool.homeViewModel(consoles: []),
            libraryViewModel: PreviewObjectPool.libraryViewModel(games: [])
        )
    }
}

#Preview("Failed") {
    NavigationStack {
        HomeView(
            homeViewModel: PreviewObjectPool.homeViewModel(
                state: PreviewObjectPool.failedLoadState
            ),
            libraryViewModel: PreviewObjectPool.libraryViewModel()
        )
    }
}
#endif

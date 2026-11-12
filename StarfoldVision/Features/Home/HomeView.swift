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
    @Bindable var home: HomeViewModel

    let library: LibraryViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                ConsoleShelf(home: home)

                if !library.recentGames.isEmpty {
                    RecentGamesShelf(
                        games: library.recentGames(limit: recentGameLimit),
                        onPlay: { library.play($0) }
                    )
                }
            }
            .padding(.horizontal, dimensions.spaceXXLarge)
            .padding(.vertical, dimensions.spaceXLarge)
        }
        .refreshable { await home.refreshAccount() }
        .alert(
            home.powerProblemTitle,
            isPresented: $home.isPowerProblemPresented,
            presenting: home.powerProblem
        ) { _ in
            Button("app.powerProblem.ok") {}
        } message: { problem in
            Text(problem.message)
        }
    }
}

private extension HomeView {
    var recentGameLimit: Int {
        8
    }
}

#if DEBUG
#Preview("Consoles") {
    NavigationStack {
        HomeView(
            home: PreviewObjectPool.homeViewModel(),
            library: PreviewObjectPool.libraryViewModel()
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        HomeView(
            home: PreviewObjectPool.homeViewModel(state: .loading),
            library: PreviewObjectPool.libraryViewModel()
        )
    }
}

#Preview("No consoles") {
    NavigationStack {
        HomeView(
            home: PreviewObjectPool.homeViewModel(consoles: []),
            library: PreviewObjectPool.libraryViewModel(games: [])
        )
    }
}

#Preview("Failed") {
    NavigationStack {
        HomeView(
            home: PreviewObjectPool.homeViewModel(state: PreviewObjectPool.failedLoadState),
            library: PreviewObjectPool.libraryViewModel()
        )
    }
}
#endif

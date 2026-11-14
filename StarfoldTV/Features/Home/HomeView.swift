//
//  HomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/30.
//

import StarfoldShared
import SwiftUI

struct HomeView: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var homeViewModel: HomeViewModel

    let libraryViewModel: LibraryViewModel

    let onBrowse: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
                    HomeCardRow(
                        homeViewModel: homeViewModel,
                        libraryViewModel: libraryViewModel,
                        cardWidth: cardWidth(in: geometry.size.width),
                        onBrowse: onBrowse
                    )

                    if !libraryViewModel.recentGames.isEmpty {
                        GameShelf(
                            title: "home.recentlyPlayed.title",
                            games: libraryViewModel.recentGames,
                            tileWidth: shelfTileWidth(in: geometry.size.width)
                        )
                    }
                }
                .padding(.horizontal, dimensions.spaceXXLarge)
                .padding(.top, dimensions.spaceSmall)
                .padding(.bottom, dimensions.spaceXXXLarge)
            }
            .scrollClipDisabled()
        }
        .alert(
            homeViewModel.powerProblemTitle,
            isPresented: $homeViewModel.isPowerProblemPresented,
            presenting: homeViewModel.powerProblem
        ) { _ in
            Button("common.ok") {}
        } message: { problem in
            Text(problem.message)
        }
    }

    private func cardWidth(in width: CGFloat) -> CGFloat {
        let cardsPerRow: CGFloat = 3

        return max(dimensions.homeCardMinimumWidth, columnWidth(in: width, count: cardsPerRow))
    }

    private func shelfTileWidth(in width: CGFloat) -> CGFloat {
        let shelfTilesPerRow: CGFloat = 4

        return max(dimensions.gameTileMinimumWidth, columnWidth(in: width, count: shelfTilesPerRow))
    }

    private func columnWidth(in width: CGFloat, count: CGFloat) -> CGFloat {
        let margins = 2 * dimensions.spaceXXLarge
        let gaps = (count - 1) * dimensions.spaceXXLarge
        return (width - margins - gaps) / count
    }
}

#if DEBUG
#Preview(arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) { state in
    HomeView(
        homeViewModel: PreviewObjectPool.homeViewModel(state: state),
        libraryViewModel: PreviewObjectPool.libraryViewModel(state: state),
        onBrowse: {}
    )
}

#Preview("No consoles") {
    HomeView(
        homeViewModel: PreviewObjectPool.homeViewModel(consoles: []),
        libraryViewModel: PreviewObjectPool.libraryViewModel(),
        onBrowse: {}
    )
}
#endif

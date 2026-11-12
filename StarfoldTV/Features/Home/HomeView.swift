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

    @Bindable var home: HomeViewModel
    let library: LibraryViewModel
    let onBrowse: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
                    HomeCardRow(
                        home: home,
                        library: library,
                        cardWidth: cardWidth(in: geometry.size.width),
                        onBrowse: onBrowse
                    )

                    if !library.recentGames.isEmpty {
                        GameShelf(
                            title: "home.recentlyPlayed.title",
                            games: library.recentGames,
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
            home.powerProblemTitle,
            isPresented: $home.isPowerProblemPresented,
            presenting: home.powerProblem
        ) { _ in
            Button("common.ok") {}
        } message: { problem in
            Text(problem.message)
        }
    }
}

private extension HomeView {
    var cardsPerRow: CGFloat {
        3
    }

    var shelfTilesPerRow: CGFloat {
        4
    }

    func cardWidth(in width: CGFloat) -> CGFloat {
        max(dimensions.homeCardMinimumWidth, columnWidth(in: width, count: cardsPerRow))
    }

    func shelfTileWidth(in width: CGFloat) -> CGFloat {
        max(dimensions.gameTileMinimumWidth, columnWidth(in: width, count: shelfTilesPerRow))
    }

    func columnWidth(in width: CGFloat, count: CGFloat) -> CGFloat {
        let margins = 2 * dimensions.spaceXXLarge
        let gaps = (count - 1) * dimensions.spaceXXLarge
        return (width - margins - gaps) / count
    }
}

#if DEBUG
#Preview(arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) { state in
    HomeView(
        home: PreviewObjectPool.homeViewModel(state: state),
        library: PreviewObjectPool.libraryViewModel(state: state),
        onBrowse: {}
    )
}

#Preview("No consoles") {
    HomeView(
        home: PreviewObjectPool.homeViewModel(consoles: []),
        library: PreviewObjectPool.libraryViewModel(),
        onBrowse: {}
    )
}
#endif

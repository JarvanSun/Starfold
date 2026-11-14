//
//  SearchResultsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct SearchResultsView: View {
    @Environment(\.dimensions) private var dimensions

    let libraryViewModel: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        switch libraryViewModel.hasNoSearchResults {
        case true: ContentUnavailableView.search(text: libraryViewModel.searchText)
        case false: grid
        }
    }

    private var grid: some View {
        ScrollView {
            GameGrid(
                games: libraryViewModel.searchResults,
                onPlay: { libraryViewModel.play($0) },
                onOpen: { onOpenGame($0) }
            )
            .padding(.vertical, dimensions.spaceLarge)
        }
    }
}

#if DEBUG
#Preview("Search", arguments: ["King", "No such game"]) { searchText in
    let libraryViewModel = PreviewObjectPool.libraryViewModel()
    libraryViewModel.searchText = searchText

    return NavigationStack {
        SearchResultsView(libraryViewModel: libraryViewModel) { _ in }
            .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}
#endif

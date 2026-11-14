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
    @FocusState private var isFirstResultFocused: Bool

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
                onOpen: { onOpenGame($0) },
                firstTileFocus: $isFirstResultFocused
            )
            .padding(.vertical, dimensions.spaceLarge)
        }
        .defaultFocus($isFirstResultFocused, true)
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

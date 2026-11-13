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

    let library: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        switch library.hasNoSearchResults {
        case true: ContentUnavailableView.search(text: library.searchText)
        case false: grid
        }
    }

    private var grid: some View {
        ScrollView {
            GameGrid(
                games: library.searchResults,
                onPlay: { library.play($0) },
                onOpen: { onOpenGame($0) }
            )
            .padding(.vertical, dimensions.spaceLarge)
        }
    }
}

#if DEBUG
#Preview("Search", arguments: ["King", "No such game"]) { searchText in
    let library = PreviewObjectPool.libraryViewModel()
    library.searchText = searchText

    return NavigationStack {
        SearchResultsView(library: library) { _ in }
            .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}
#endif

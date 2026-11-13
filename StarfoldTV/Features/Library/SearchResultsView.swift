//
//  SearchResultsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SearchResultsView: View {
    @Environment(\.dimensions) private var dimensions

    let library: LibraryViewModel

    var body: some View {
        switch library.hasNoSearchResults {
        case true: ContentUnavailableView.search(text: library.searchText)
        case false: grid
        }
    }

    private var grid: some View {
        ScrollView {
            GameGrid(games: library.searchResults)
                .padding(.horizontal, dimensions.spaceHuge)
                .padding(.vertical, dimensions.spaceXXXLarge)
        }
        .scrollClipDisabled()
    }
}

#if DEBUG
#Preview("Search", arguments: ["King", "No such game"]) { searchText in
    let library = PreviewObjectPool.libraryViewModel()
    library.searchText = searchText

    return SearchResultsView(library: library)
}
#endif

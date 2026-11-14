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

    let libraryViewModel: LibraryViewModel

    var body: some View {
        if libraryViewModel.hasNoSearchResults {
            ContentUnavailableView.search(text: libraryViewModel.searchText)
        } else {
            grid
        }
    }

    private var grid: some View {
        ScrollView {
            GameGrid(games: libraryViewModel.searchResults)
                .padding(.horizontal, dimensions.spaceHuge)
                .padding(.vertical, dimensions.spaceXXXLarge)
        }
        .scrollClipDisabled()
    }
}

#if DEBUG
#Preview("Search", arguments: ["King", "No such game"]) { searchText in
    let libraryViewModel = PreviewObjectPool.libraryViewModel()
    libraryViewModel.searchText = searchText

    return SearchResultsView(libraryViewModel: libraryViewModel)
}
#endif

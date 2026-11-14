//
//  LibraryView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibraryView: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var libraryViewModel: LibraryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                if !libraryViewModel.isSearching {
                    ForEach(libraryViewModel.shelves) { shelf($0) }
                }

                if !libraryViewModel.visibleGames.isEmpty {
                    GameGrid(
                        title: libraryViewModel.gamesTitle,
                        games: libraryViewModel.visibleGames,
                        onPlay: { libraryViewModel.play($0) }
                    )
                }
            }
            .padding(.horizontal, dimensions.spaceXXLarge)
            .padding(.vertical, dimensions.spaceXLarge)
        }
        .overlay(if: libraryViewModel.placeholder) { placeholderView($0) }
        .navigationTitle("library.title")
        .searchable(text: $libraryViewModel.searchText, prompt: Text("library.search.prompt"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SortPicker(sort: $libraryViewModel.sort, choices: libraryViewModel.sortChoices)
            }
        }
        .refreshable { await libraryViewModel.refresh() }
    }

    private func shelf(_ shelf: LibraryShelf) -> some View {
        GameShelf(
            shelf: shelf,
            games: libraryViewModel.games(on: shelf),
            onPlay: { libraryViewModel.play($0) }
        )
    }

    private func placeholderView(_ placeholder: LibraryPlaceholder) -> some View {
        LibraryPlaceholderView(
            placeholder: placeholder,
            searchText: libraryViewModel.searchText,
            onRetry: { refresh() }
        )
    }

    private func refresh() {
        Task { await libraryViewModel.refresh() }
    }
}

#if DEBUG
#Preview("Games") {
    NavigationStack {
        LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel())
    }
}

#Preview("Loading") {
    NavigationStack {
        LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel(state: .loading))
    }
}

#Preview("Failed") {
    NavigationStack {
        LibraryView(
            libraryViewModel: PreviewObjectPool.libraryViewModel(
                state: PreviewObjectPool.failedLoadState
            )
        )
    }
}

#Preview("Unavailable") {
    NavigationStack {
        LibraryView(
            libraryViewModel: PreviewObjectPool.libraryViewModel(games: [], access: .unavailable)
        )
    }
}
#endif

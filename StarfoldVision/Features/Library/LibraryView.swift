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
    @Bindable var library: LibraryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                if !library.isSearching {
                    ForEach(library.shelves) { shelf($0) }
                }

                if !library.visibleGames.isEmpty {
                    GameGrid(
                        title: library.gamesTitle,
                        games: library.visibleGames,
                        onPlay: { library.play($0) }
                    )
                }
            }
            .padding(.horizontal, dimensions.spaceXXLarge)
            .padding(.vertical, dimensions.spaceXLarge)
        }
        .overlay(if: library.placeholder) { placeholderView($0) }
        .navigationTitle("library.title")
        .searchable(text: $library.searchText, prompt: Text("library.search.prompt"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SortPicker(sort: $library.sort, choices: library.sortChoices)
            }
        }
        .refreshable { await library.refresh() }
    }

    private func shelf(_ shelf: LibraryShelf) -> some View {
        GameShelf(shelf: shelf, games: library.games(on: shelf), onPlay: { library.play($0) })
    }

    private func placeholderView(_ placeholder: LibraryPlaceholder) -> some View {
        LibraryPlaceholderView(
            placeholder: placeholder,
            searchText: library.searchText,
            onRetry: { refresh() }
        )
    }

    private func refresh() {
        Task { await library.refresh() }
    }
}

#if DEBUG
#Preview("Games") {
    NavigationStack {
        LibraryView(library: PreviewObjectPool.libraryViewModel())
    }
}

#Preview("Loading") {
    NavigationStack {
        LibraryView(library: PreviewObjectPool.libraryViewModel(state: .loading))
    }
}

#Preview("Failed") {
    NavigationStack {
        LibraryView(
            library: PreviewObjectPool.libraryViewModel(state: PreviewObjectPool.failedLoadState)
        )
    }
}

#Preview("Unavailable") {
    NavigationStack {
        LibraryView(library: PreviewObjectPool.libraryViewModel(games: [], access: .unavailable))
    }
}
#endif

//
//  LibraryView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct LibraryView: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var libraryViewModel: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                if !libraryViewModel.isSearching {
                    ForEach(libraryViewModel.shelves) { shelfRow($0) }
                }

                if !libraryViewModel.visibleGames.isEmpty {
                    AllGamesGrid(libraryViewModel: libraryViewModel, onOpenGame: onOpenGame)
                }
            }
            .padding(.vertical, dimensions.spaceXLarge)
            .animation(.smooth(duration: 0.3), value: libraryViewModel.isSearching)
        }
        .overlay(if: libraryViewModel.placeholder) { placeholderView($0) }
        .searchable(
            text: $libraryViewModel.searchText,
            placement: .toolbar,
            prompt: Text("library.search.prompt")
        )
        .navigationTitle(Text("library.title"))
        .refreshable { await libraryViewModel.refresh() }
    }

    private func shelfRow(_ shelf: LibraryShelf) -> some View {
        ShelfRow(
            shelf: shelf,
            games: libraryViewModel.games(on: shelf),
            onPlay: { libraryViewModel.play($0) },
            onOpen: onOpenGame
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
@available(macOS 27, *)
#Preview("Library", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel(state: state)) { _ in }
            .background { SkyBackground() }
    }
    .frame(width: 1180, height: 820)
    .environment(\.colorScheme, .dark)
}

#Preview("No cloud gaming") {
    NavigationStack {
        LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel(access: .unavailable)) {
            _ in
        }
        .background { SkyBackground() }
    }
    .frame(width: 1180, height: 820)
    .environment(\.colorScheme, .dark)
}
#endif

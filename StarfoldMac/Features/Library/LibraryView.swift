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
    @Bindable var library: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                if !library.isSearching {
                    ForEach(library.shelves, content: shelfRow(_:))
                }

                if !library.visibleGames.isEmpty {
                    AllGamesGrid(library: library, onOpenGame: onOpenGame)
                }
            }
            .padding(.vertical, dimensions.spaceXLarge)
            .animation(.smooth(duration: 0.3), value: library.isSearching)
        }
        .overlay(if: library.placeholder, content: placeholderView(_:))
        .searchable(
            text: $library.searchText,
            placement: .toolbar,
            prompt: Text("library.search.prompt")
        )
        .navigationTitle(Text("library.title"))
        .refreshable { await library.refresh() }
    }
}

private extension LibraryView {
    func shelfRow(_ shelf: LibraryShelf) -> some View {
        ShelfRow(
            shelf: shelf,
            games: library.games(on: shelf),
            onPlay: library.play(_:),
            onOpen: onOpenGame
        )
    }

    func placeholderView(_ placeholder: LibraryPlaceholder) -> some View {
        LibraryPlaceholderView(
            placeholder: placeholder,
            searchText: library.searchText,
            onRetry: refresh
        )
    }

    func refresh() {
        Task { await library.refresh() }
    }
}

#if DEBUG
@available(macOS 27, *)
#Preview("Library", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        LibraryView(library: PreviewObjectPool.libraryViewModel(state: state)) { _ in }
            .background { SkyBackground() }
    }
    .frame(width: 1180, height: 820)
    .environment(\.colorScheme, .dark)
}

#Preview("No cloud gaming") {
    NavigationStack {
        LibraryView(library: PreviewObjectPool.libraryViewModel(access: .unavailable)) { _ in }
            .background { SkyBackground() }
    }
    .frame(width: 1180, height: 820)
    .environment(\.colorScheme, .dark)
}
#endif

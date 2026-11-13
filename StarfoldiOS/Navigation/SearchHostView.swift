//
//  SearchHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct SearchHostView: View {
    @State private var path: [CloudGame] = []

    @Bindable var library: LibraryViewModel

    var body: some View {
        NavigationStack(path: $path) {
            SearchResultsView(library: library, onOpenGame: { path.append($0) })
                .background { SkyBackground() }
                .navigationTitle(Text("search.title"))
                .searchable(text: $library.searchText, prompt: Text("search.field.prompt"))
                .navigationDestination(for: CloudGame.self) { gameDetail($0) }
        }
    }

    private func gameDetail(_ game: CloudGame) -> some View {
        GameDetailView(detail: library.detail(for: game))
            .background { SkyBackground() }
    }
}

#if DEBUG
#Preview {
    SearchHostView(library: PreviewObjectPool.libraryViewModel())
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

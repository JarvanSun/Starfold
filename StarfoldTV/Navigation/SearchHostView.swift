//
//  SearchHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct SearchHostView: View {
    @Environment(AppViewModel.self) private var app
    @State private var path: [CloudGame] = []

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
        .onChange(of: app.activeAccountID) { path.removeAll() }
    }
}

private extension SearchHostView {
    @ViewBuilder
    var content: some View {
        switch app.library {
        case let library?: results(in: library)
        case nil: LoadingView()
        }
    }

    func results(in library: LibraryViewModel) -> some View {
        SearchResultsView(library: library)
            .searchable(text: Bindable(library).searchText, prompt: Text("search.field.prompt"))
            .navigationDestination(for: CloudGame.self) { game in
                GameDetailView(detail: library.detail(for: game))
            }
    }
}

#if DEBUG
#Preview {
    SearchHostView()
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

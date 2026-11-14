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
    @Environment(AppViewModel.self) private var appViewModel
    @State private var searchPath: [CloudGame] = []

    var body: some View {
        NavigationStack(path: $searchPath) {
            content
        }
        .onChange(of: appViewModel.activeAccountID) { searchPath.removeAll() }
    }

    @ViewBuilder
    private var content: some View {
        switch appViewModel.libraryViewModel {
        case let library?: results(in: library)
        case nil: LoadingView()
        }
    }

    private func results(in library: LibraryViewModel) -> some View {
        SearchResultsView(libraryViewModel: library)
            .searchable(text: Bindable(library).searchText, prompt: Text("search.field.prompt"))
            .navigationDestination(for: CloudGame.self) { game in
                GameDetailView(gameDetailViewModel: library.makeGameDetailViewModel(for: game))
            }
    }
}

#if DEBUG
#Preview {
    SearchHostView()
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

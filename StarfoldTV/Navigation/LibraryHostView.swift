//
//  LibraryHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct LibraryHostView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Binding var path: [CloudGame]

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
        .onChange(of: appViewModel.activeAccountID) { path.removeAll() }
    }

    @ViewBuilder
    private var content: some View {
        switch appViewModel.libraryViewModel {
        case let library?: page(library)
        case nil: LoadingView()
        }
    }

    private func page(_ library: LibraryViewModel) -> some View {
        LibraryView(libraryViewModel: library)
            .navigationDestination(for: CloudGame.self) { game in
                GameDetailView(gameDetailViewModel: library.makeGameDetailViewModel(for: game))
            }
    }
}

#if DEBUG
#Preview {
    LibraryHostView(path: .constant([]))
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

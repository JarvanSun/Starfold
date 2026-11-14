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
    let libraryViewModel: LibraryViewModel

    var body: some View {
        NavigationStack {
            LibraryView(libraryViewModel: libraryViewModel)
                .navigationDestination(for: CloudGame.self) { gameDetail($0) }
        }
    }

    private func gameDetail(_ game: CloudGame) -> some View {
        GameDetailView(gameDetailViewModel: libraryViewModel.detail(for: game))
    }
}

#if DEBUG
#Preview("Cloud Gaming") {
    LibraryHostView(libraryViewModel: PreviewObjectPool.libraryViewModel())
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

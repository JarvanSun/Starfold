//
//  LibraryHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct LibraryHostView: View {
    @State private var path: [CloudGame] = []

    let library: LibraryViewModel

    var body: some View {
        NavigationStack(path: $path) {
            LibraryView(library: library, onOpenGame: { path.append($0) })
                .background { SkyBackground() }
                .navigationDestination(for: CloudGame.self) { gameDetail($0) }
        }
    }

    private func gameDetail(_ game: CloudGame) -> some View {
        GameDetailView(detail: library.detail(for: game))
            .background { SkyBackground() }
    }
}

#if DEBUG
#Preview("Cloud Gaming") {
    LibraryHostView(library: PreviewObjectPool.libraryViewModel())
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

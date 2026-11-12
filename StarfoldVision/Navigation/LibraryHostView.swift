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
    let library: LibraryViewModel

    var body: some View {
        NavigationStack {
            LibraryView(library: library)
                .navigationDestination(for: CloudGame.self, destination: gameDetail(_:))
        }
    }
}

private extension LibraryHostView {
    func gameDetail(_ game: CloudGame) -> some View {
        GameDetailView(detail: library.detail(for: game))
    }
}

#if DEBUG
#Preview("Cloud Gaming") {
    LibraryHostView(library: PreviewObjectPool.libraryViewModel())
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

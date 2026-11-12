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
    @Environment(AppViewModel.self) private var app
    @Binding var path: [CloudGame]

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
        .onChange(of: app.activeAccountID) { path.removeAll() }
    }
}

private extension LibraryHostView {
    @ViewBuilder
    var content: some View {
        switch app.library {
        case let library?: page(library)
        case nil: LoadingView()
        }
    }

    func page(_ library: LibraryViewModel) -> some View {
        LibraryView(library: library)
            .navigationDestination(for: CloudGame.self) { game in
                GameDetailView(detail: library.detail(for: game))
            }
    }
}

#if DEBUG
#Preview {
    LibraryHostView(path: .constant([]))
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

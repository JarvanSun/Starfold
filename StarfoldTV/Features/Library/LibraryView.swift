//
//  LibraryView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibraryView: View {
    @Environment(\.dimensions) private var dimensions

    let library: LibraryViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXXXLarge) {
                switch library.placeholder {
                case .loading: LoadingView()
                case .failed(let reason): LibraryFailedMessage(reason: reason, onRetry: refresh)
                case .unavailable: LibraryUnavailableMessage(onRefresh: refresh)
                case .noResults, nil: LibraryShelves(library: library)
                }
            }
            .padding(.horizontal, dimensions.spaceHuge)
            .padding(.vertical, dimensions.spaceXXXLarge)
        }
        .scrollClipDisabled()
    }
}

private extension LibraryView {
    func refresh() {
        Task { await library.refresh() }
    }
}

#if DEBUG
#Preview(arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) { state in
    LibraryView(library: PreviewObjectPool.libraryViewModel(state: state))
}

#Preview("Access", arguments: [CloudAccess.freeToPlay, .unavailable]) { access in
    LibraryView(library: PreviewObjectPool.libraryViewModel(access: access))
}
#endif

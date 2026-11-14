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

    let libraryViewModel: LibraryViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXXXLarge) {
                switch libraryViewModel.placeholder {
                case .loading: LoadingView()
                case .failed(let reason):
                    LibraryFailedMessage(reason: reason, onRetry: { refresh() })
                case .unavailable: LibraryUnavailableMessage(onRefresh: { refresh() })
                case .noResults, nil: LibraryShelves(libraryViewModel: libraryViewModel)
                }
            }
            .padding(.horizontal, dimensions.spaceHuge)
            .padding(.vertical, dimensions.spaceXXXLarge)
        }
        .scrollClipDisabled()
    }

    private func refresh() {
        Task { await libraryViewModel.refresh() }
    }
}

#if DEBUG
#Preview(arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) { state in
    LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel(state: state))
}

#Preview("Access", arguments: [CloudAccess.freeToPlay, .unavailable]) { access in
    LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel(access: access))
}
#endif

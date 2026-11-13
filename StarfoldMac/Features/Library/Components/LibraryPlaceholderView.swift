//
//  LibraryPlaceholderView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibraryPlaceholderView: View {
    let placeholder: LibraryPlaceholder
    let searchText: String

    let onRetry: () -> Void

    var body: some View {
        switch placeholder {
        case .loading: LibrarySkeleton()
        case .failed(let message): failedCard(message)
        case .unavailable: unavailableCard
        case .noResults: ContentUnavailableView.search(text: searchText)
        }
    }

    private func failedCard(_ message: String) -> some View {
        MessageCard(
            symbol: "exclamationmark.triangle",
            title: String(localized: "library.failed.title"),
            message: message
        ) {
            Button(String(localized: "library.failed.retry")) { onRetry() }
        }
    }

    private var unavailableCard: some View {
        MessageCard(
            symbol: "cloud.slash",
            title: String(localized: "library.unavailable.title"),
            message: String(localized: "library.unavailable.message")
        ) {
            Button(String(localized: "library.unavailable.retry")) { onRetry() }
        }
    }
}

#if DEBUG
@available(macOS 27, *)
#Preview(
    arguments: [
        LibraryPlaceholder.loading,
        .failed("The network connection was lost."),
        .unavailable,
        .noResults,
    ]
) { placeholder in
    LibraryPlaceholderView(placeholder: placeholder, searchText: "Halo") {}
        .frame(width: 900, height: 500)
        .environment(\.colorScheme, .dark)
}
#endif

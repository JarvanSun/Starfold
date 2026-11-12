//
//  LibraryPlaceholderView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibraryPlaceholderView: View {
    @Environment(\.dimensions) private var dimensions

    let placeholder: LibraryPlaceholder
    let searchText: String

    let onRetry: () -> Void

    var body: some View {
        switch placeholder {
        case .loading: ProgressView()
        case .failed(let message): loadFailure(message)
        case .unavailable: cloudUnavailable
        case .noResults: ContentUnavailableView.search(text: searchText)
        }
    }
}

private extension LibraryPlaceholderView {
    func loadFailure(_ message: String) -> some View {
        MessageView(
            symbol: "exclamationmark.triangle",
            title: "library.failed.title",
            message: Text(message)
        ) {
            Button("library.failed.retry", action: onRetry)
        }
        .padding(dimensions.spaceXXLarge)
    }

    var cloudUnavailable: some View {
        MessageView(
            symbol: "cloud.slash",
            title: "library.unavailable.title",
            message: Text("library.unavailable.message")
        ) {
            Button("library.unavailable.retry", action: onRetry)
        }
        .padding(dimensions.spaceXXLarge)
    }
}

#if DEBUG
#Preview(
    "Placeholders",
    arguments: [
        LibraryPlaceholder.loading,
        .failed("The network connection was lost."),
        .unavailable,
        .noResults,
    ]
) { placeholder in
    LibraryPlaceholderView(placeholder: placeholder, searchText: "Halo") {}
}
#endif

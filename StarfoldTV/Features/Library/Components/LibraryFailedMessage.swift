//
//  LibraryFailedMessage.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct LibraryFailedMessage: View {
    let reason: String

    let onRetry: () -> Void

    var body: some View {
        MessageView(
            title: "library.failed.title",
            message: Text(reason),
            actionLabel: "library.failed.retry",
            onAction: onRetry
        )
    }
}

#if DEBUG
#Preview {
    LibraryFailedMessage(reason: "The network connection was lost.") {}
}
#endif

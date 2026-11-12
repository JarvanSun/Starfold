//
//  ConsolesFailedMessage.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct ConsolesFailedMessage: View {
    let message: String

    let onRetry: () -> Void

    var body: some View {
        MessageView(
            symbol: "exclamationmark.triangle",
            title: "home.consoles.failed.title",
            message: Text(message)
        ) {
            Button("home.consoles.failed.retry", action: onRetry)
        }
    }
}

#if DEBUG
#Preview("Consoles failed") {
    ConsolesFailedMessage(message: "The network connection was lost.") {}
        .padding()
}
#endif

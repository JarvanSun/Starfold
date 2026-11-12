//
//  ConsolesFailedCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct ConsolesFailedCard: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        MessageCard(
            symbol: "exclamationmark.triangle",
            title: String(localized: "home.consoles.failed.title"),
            message: message
        ) {
            Button(String(localized: "home.consoles.failed.retry"), action: onRetry)
        }
    }
}

#if DEBUG
#Preview {
    ConsolesFailedCard(message: "The network connection was lost.") {}
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif

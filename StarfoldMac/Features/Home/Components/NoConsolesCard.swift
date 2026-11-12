//
//  NoConsolesCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct NoConsolesCard: View {
    let onRefresh: () -> Void

    var body: some View {
        MessageCard(
            symbol: "logo.xbox",
            title: String(localized: "home.consoles.empty.title"),
            message: String(localized: "home.consoles.empty.message")
        ) {
            Button(String(localized: "home.consoles.empty.refresh"), action: onRefresh)
        }
    }
}

#if DEBUG
#Preview {
    NoConsolesCard {}
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif

//
//  NoConsolesMessage.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct NoConsolesMessage: View {
    let onRefresh: () -> Void

    var body: some View {
        MessageView(
            symbol: "logo.xbox",
            title: "home.consoles.empty.title",
            message: Text("home.consoles.empty.message")
        ) {
            Button("home.consoles.empty.refresh", action: onRefresh)
        }
    }
}

#if DEBUG
#Preview("No consoles") {
    NoConsolesMessage {}
        .padding()
}
#endif

//
//  MessageView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct MessageView<Actions: View>: View {
    @Environment(\.dimensions) private var dimensions

    let symbol: String
    let title: LocalizedStringResource
    let message: Text
    @ViewBuilder let actions: Actions

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: symbol)
        } description: {
            message
        } actions: {
            actions
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, dimensions.spaceXLarge)
        .background(.regularMaterial, in: .rect(cornerRadius: dimensions.cornerRadiusXXLarge))
    }
}

#if DEBUG
#Preview("Message") {
    MessageView(
        symbol: "logo.xbox",
        title: "home.consoles.empty.title",
        message: Text("home.consoles.empty.message")
    ) {
        Button("home.consoles.empty.refresh") {}
    }
    .padding()
}
#endif

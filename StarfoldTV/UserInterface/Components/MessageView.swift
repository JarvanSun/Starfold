//
//  MessageView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct MessageView: View {
    @Environment(\.dimensions) private var dimensions

    let title: LocalizedStringResource
    let message: Text
    let actionLabel: LocalizedStringResource
    var size = MessageSize.regular

    let onAction: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            Text(title).font(titleFont)

            message
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(actionLabel) { onAction() }.buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(padding)
    }

    private var titleFont: Font {
        switch size {
        case .regular: .title.bold()
        case .compact: .headline
        }
    }

    private var padding: CGFloat {
        switch size {
        case .regular: dimensions.spaceXXXLarge
        case .compact: dimensions.spaceXLarge
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        MessageView(
            title: "library.unavailable.title",
            message: Text("library.unavailable.message"),
            actionLabel: "library.unavailable.refresh",
            onAction: {}
        )

        MessageView(
            title: "home.consoles.empty.title",
            message: Text("home.consoles.empty.message"),
            actionLabel: "home.consoles.refresh",
            size: .compact,
            onAction: {}
        )
    }
}
#endif

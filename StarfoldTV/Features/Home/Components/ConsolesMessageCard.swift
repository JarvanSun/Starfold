//
//  ConsolesMessageCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct ConsolesMessageCard: View {
    @Environment(\.dimensions) private var dimensions

    let title: LocalizedStringResource
    let message: Text
    let width: CGFloat
    let onRefresh: () -> Void

    var body: some View {
        MessageView(
            title: title,
            message: message,
            actionLabel: "home.consoles.refresh",
            onAction: onRefresh,
            size: .compact
        )
        .frame(width: width, height: dimensions.homeCardHeight(width: width))
        .cardSurface(cornerRadius: dimensions.cornerRadiusXLarge)
    }
}

#if DEBUG
#Preview {
    ConsolesMessageCard(
        title: "home.consoles.empty.title",
        message: Text("home.consoles.empty.message"),
        width: 480,
        onRefresh: {}
    )
}
#endif

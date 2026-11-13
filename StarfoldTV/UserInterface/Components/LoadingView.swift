//
//  LoadingView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LoadingView: View {
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        let cardCount = 3

        HStack(spacing: dimensions.spaceXXLarge) {
            ForEach(0..<cardCount, id: \.self) { _ in placeholderCard }
        }
        .accessibilityLabel(Text("common.loading"))
    }
}

private extension LoadingView {
    var placeholderCard: some View {
        RoundedRectangle(cornerRadius: dimensions.cornerRadiusXLarge)
            .fill(Color.cardFill)
            .frame(width: dimensions.loadingCardWidth, height: dimensions.loadingCardHeight)
            .redacted(reason: .placeholder)
    }
}

#if DEBUG
#Preview {
    LoadingView()
}
#endif

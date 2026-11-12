//
//  FavoriteButton.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct FavoriteButton: View {
    let action: FavoriteAction

    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            Label(action.title, systemImage: action.symbol)
                .contentTransition(.symbolEffect(.replace))
        }
        .labelStyle(.iconOnly)
        .buttonBorderShape(.circle)
        .controlSize(.extraLarge)
    }
}

#if DEBUG
#Preview("Favorite buttons") {
    HStack {
        FavoriteButton(action: .add) {}

        FavoriteButton(action: .remove) {}
    }
    .padding()
}
#endif

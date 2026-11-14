//
//  FavoriteButton.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct FavoriteButton: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let action: FavoriteAction
    let isFavorite: Bool

    let onToggle: () -> Void

    var body: some View {
        Button {
            toggle()
        } label: {
            Label(action.title, systemImage: action.symbol)
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(style)
        }
        .buttonStyle(CircleIconButtonStyle(size: dimensions.gameFavoriteButtonSize))
        .help(Text(action.title))
    }

    private func toggle() {
        withAnimation(.spring(duration: 0.3, bounce: 0.5), onToggle)
    }

    private var style: AnyShapeStyle {
        isFavorite ? .init(palette.primaryTint) : .init(.white)
    }
}

#if DEBUG
#Preview {
    HStack {
        FavoriteButton(action: .add, isFavorite: false) {}

        FavoriteButton(action: .remove, isFavorite: true) {}
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif

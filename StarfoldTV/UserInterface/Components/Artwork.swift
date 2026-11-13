//
//  Artwork.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct Artwork: View {
    let url: URL?

    var body: some View {
        ZStack {
            Color.cardFill

            placeholderSymbol

            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.clear
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }

    private var placeholderSymbol: some View {
        Image(systemName: "gamecontroller")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }
}

#if DEBUG
#Preview {
    HStack {
        Artwork(url: PreviewObjectPool.cloudGames[0].product?.posterImage)

        Artwork(url: nil)
    }
}
#endif

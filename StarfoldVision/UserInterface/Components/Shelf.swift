//
//  Shelf.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct Shelf<Content: View>: View {
    @Environment(\.dimensions) private var dimensions

    let title: LocalizedStringResource
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: dimensions.spaceXLarge) {
                    content
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }
}

#if DEBUG
#Preview("Shelf") {
    Shelf(title: LibraryShelf.recentlyAdded.title) {
        ForEach(PreviewObjectPool.cloudGames) { game in
            GameTile(game: game)
        }
    }
    .padding()
}
#endif

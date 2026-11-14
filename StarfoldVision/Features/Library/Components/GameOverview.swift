//
//  GameOverview.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameOverview: View {
    @Environment(\.dimensions) private var dimensions

    let about: String?
    let facts: [GameFact]

    var body: some View {
        HStack(alignment: .top, spacing: dimensions.spaceXXXLarge) {
            if let about {
                aboutSection(about)
            }

            GameFacts(facts: facts)
        }
    }

    private func aboutSection(_ about: String) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            Text("game.about.title")
                .font(.title2.bold())

            Text(about)
                .foregroundStyle(.secondary)
                .lineSpacing(dimensions.spaceXSmall)
        }
        .frame(maxWidth: dimensions.readableTextMaximumWidth, alignment: .leading)
    }
}

#if DEBUG
#Preview("Game overview") {
    let detail = PreviewObjectPool.gameDetailViewModel

    GameOverview(about: detail.about, facts: detail.facts)
        .padding()
}
#endif

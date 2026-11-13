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
        HStack(alignment: .top, spacing: dimensions.spaceXXLarge) {
            switch about {
            case let about?: aboutSection(about)
            case nil: EmptyView()
            }

            GameFacts(facts: facts)
        }
    }

    private func aboutSection(_ about: String) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text("gameDetail.about.title")
                .font(.title3.bold())

            Text(about)
                .foregroundStyle(.secondary)
                .lineSpacing(dimensions.spaceXSmall)
                .textSelection(.enabled)
        }
        .frame(maxWidth: dimensions.gameDescriptionMaxWidth, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    let detail = PreviewObjectPool.gameDetailViewModel
    GameOverview(about: detail.about, facts: detail.facts)
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif

//
//  GameFacts.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameFacts: View {
    @Environment(\.dimensions) private var dimensions

    let facts: [GameFact]

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            ForEach(facts) { row($0) }
        }
        .frame(width: dimensions.gameFactsWidth, alignment: .leading)
    }

    private func row(_ fact: GameFact) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXSmall) {
            Text(fact.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)

            Text(fact.value)
                .font(.callout)
        }
    }
}

#if DEBUG
#Preview("Game facts") {
    GameFacts(facts: PreviewObjectPool.gameDetailViewModel.facts)
        .padding()
}
#endif

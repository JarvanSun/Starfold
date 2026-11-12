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
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            ForEach(facts, content: row(_:))
        }
        .frame(width: dimensions.gameFactsWidth, alignment: .leading)
    }
}

private extension GameFacts {
    func row(_ fact: GameFact) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXXSmall) {
            Text(fact.label)
                .textCase(.uppercase)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)

            Text(fact.value)
                .font(.callout)
        }
    }
}

#if DEBUG
#Preview {
    GameFacts(facts: PreviewObjectPool.gameDetailViewModel.facts)
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif

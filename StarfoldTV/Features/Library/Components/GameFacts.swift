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
        HStack(alignment: .top, spacing: dimensions.spaceHuge) {
            ForEach(facts) { column($0) }
        }
    }
}

private extension GameFacts {
    func column(_ fact: GameFact) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text(fact.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)

            Text(fact.value)
                .foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    GameFacts(facts: PreviewObjectPool.gameDetailViewModel.facts)
}
#endif

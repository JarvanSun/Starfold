//
//  GameOverview.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct GameOverview: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dimensions) private var dimensions

    let about: String?
    let facts: [GameFact]

    var body: some View {
        layout {
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

    private var layout: AnyLayout {
        switch horizontalSizeClass {
        case .compact: .init(VStackLayout(alignment: .leading, spacing: dimensions.spaceXLarge))
        default: .init(HStackLayout(alignment: .top, spacing: dimensions.spaceXXLarge))
        }
    }
}

#if DEBUG
#Preview {
    let gameDetailViewModel = PreviewObjectPool.gameDetailViewModel
    GameOverview(about: gameDetailViewModel.about, facts: gameDetailViewModel.facts)
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif

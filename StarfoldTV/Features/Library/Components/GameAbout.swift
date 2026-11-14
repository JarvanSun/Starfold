//
//  GameAbout.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameAbout: View {
    @Environment(\.dimensions) private var dimensions

    let about: String?

    var body: some View {
        if let about {
            section(about)
        }
    }

    private func section(_ about: String) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
            Text("game.about.title").font(.title2.bold())

            Text(about).foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    GameAbout(about: PreviewObjectPool.gameDetailViewModel.about)
}
#endif

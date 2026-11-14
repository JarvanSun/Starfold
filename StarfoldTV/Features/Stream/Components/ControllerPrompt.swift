//
//  ControllerPrompt.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct ControllerPrompt: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dimensions) private var dimensions

    let hasController: Bool

    let onCheckAgain: () -> Void
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXXLarge) {
            Image(systemName: "gamecontroller").font(.largeTitle)

            Text("controller.missing.title").font(.title.bold())

            Text("controller.missing.instructions")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            primaryButton

            Button("common.cancel") { dismiss() }
        }
        .padding(dimensions.spaceHuge)
        .onExitCommand { dismiss() }
    }

    @ViewBuilder
    private var primaryButton: some View {
        if hasController {
            Button("controller.prompt.play") { play() }
        } else {
            Button("controller.missing.checkAgain") { onCheckAgain() }
        }
    }

    private func play() {
        dismiss()

        onPlay()
    }
}

#if DEBUG
#Preview {
    ControllerPrompt(hasController: false, onCheckAgain: {}, onPlay: {})
}
#endif

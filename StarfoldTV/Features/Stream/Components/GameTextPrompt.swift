//
//  GameTextPrompt.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameTextPrompt: View {
    @Environment(\.dimensions) private var dimensions
    @Binding var text: String

    let title: String
    let description: String

    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                if !description.isEmpty {
                    Text(description)
                }

                TextField(title, text: $text)
                    .onSubmit(onSubmit)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { onCancel() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("stream.dialog.done") { onSubmit() }
                }
            }
        }
        .frame(width: dimensions.gameTextPromptWidth, height: dimensions.gameTextPromptHeight)
        .onExitCommand { onCancel() }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var text = PreviewObjectPool.textPromptText
    GameTextPrompt(
        text: $text,
        title: PreviewObjectPool.textPromptTitle,
        description: PreviewObjectPool.textPromptDescription,
        onSubmit: {},
        onCancel: {}
    )
}
#endif

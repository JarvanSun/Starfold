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

    let title: String
    let description: String
    @Binding var text: String
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
                    Button("stream.dialog.cancel", action: onCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("stream.dialog.done", action: onSubmit)
                }
            }
        }
        .frame(width: dimensions.gameDialogWidth, height: dimensions.gameTextPromptHeight)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var text = PreviewObjectPool.textPromptText
    GameTextPrompt(
        title: PreviewObjectPool.textPromptTitle,
        description: PreviewObjectPool.textPromptDescription,
        text: $text,
        onSubmit: {},
        onCancel: {}
    )
}
#endif

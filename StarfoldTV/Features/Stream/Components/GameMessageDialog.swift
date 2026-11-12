//
//  GameMessageDialog.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameMessageDialog: View {
    @Environment(\.dimensions) private var dimensions
    @Namespace private var focusScope

    let title: String
    let text: String
    let buttons: [DialogButton]
    let onAnswer: (Int) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            if !title.isEmpty {
                Text(title)
                    .font(.title2.bold())
            }

            if !text.isEmpty {
                Text(text)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: dimensions.spaceLarge) {
                ForEach(buttons, content: answerButton(_:))
            }
            .focusScope(focusScope)
        }
        .padding(dimensions.spaceXXLarge)
        .frame(minWidth: dimensions.gameDialogMinimumWidth)
        .onExitCommand(perform: onCancel)
    }
}

private extension GameMessageDialog {
    @ViewBuilder
    func answerButton(_ button: DialogButton) -> some View {
        switch button.role {
        case .primary:
            Button(button.title) { onAnswer(button.index) }
                .buttonStyle(.borderedProminent)
                .prefersDefaultFocus(true, in: focusScope)
        case .cancel, .plain: Button(button.title) { onAnswer(button.index) }
        }
    }
}

#if DEBUG
#Preview {
    GameMessageDialog(
        title: PreviewObjectPool.messageDialogTitle,
        text: PreviewObjectPool.messageDialogText,
        buttons: PreviewObjectPool.messageDialogButtons,
        onAnswer: { _ in },
        onCancel: {}
    )
}
#endif

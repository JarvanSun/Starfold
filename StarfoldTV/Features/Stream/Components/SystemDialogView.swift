//
//  SystemDialogView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct SystemDialogView: View {
    let dialogs: SystemDialogsViewModel
    let dialog: SystemDialogRequest

    var body: some View {
        let draftText: Binding<String> = .init(
            get: { dialogs.text },
            set: { dialogs.changeText(to: $0) }
        )

        switch dialog.kind {
        case .message(let title, let text, _, _, _):
            GameMessageDialog(
                title: title,
                text: text,
                buttons: dialogs.buttons(of: dialog),
                onAnswer: { answer(buttonIndex: $0) },
                onCancel: { cancel() }
            )
        case .keyboard(_, let description, _, _):
            GameTextPrompt(
                text: draftText,
                title: dialogs.textFieldTitle(of: dialog),
                description: description,
                onSubmit: { submitText() },
                onCancel: { cancel() }
            )
        }
    }

    private func answer(buttonIndex: Int) {
        dialogs.answer(dialog, buttonIndex: buttonIndex)
    }

    private func cancel() {
        dialogs.cancel(dialog)
    }

    private func submitText() {
        dialogs.submitText(for: dialog)
    }
}

#if DEBUG
#Preview("Game dialog", arguments: PreviewObjectPool.systemDialogs) { dialog in
    @Previewable @State var stream = PreviewObjectPool.streamViewModel(
        phase: .streaming,
        dialogs: [dialog]
    )

    SystemDialogView(dialogs: stream.dialogs, dialog: dialog)
}
#endif

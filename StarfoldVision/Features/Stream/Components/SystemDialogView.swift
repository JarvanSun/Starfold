//
//  SystemDialogView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
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
                onAnswer: { answer(buttonIndex: $0) }
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
}

private extension SystemDialogView {
    func answer(buttonIndex: Int) {
        dialogs.answer(dialog, buttonIndex: buttonIndex)
    }

    func submitText() {
        dialogs.submitText(for: dialog)
    }

    func cancel() {
        dialogs.cancel(dialog)
    }
}

#if DEBUG
#Preview("Message") {
    @Previewable @State var stream = PreviewObjectPool.streamViewModel(
        phase: .streaming,
        dialogs: [PreviewObjectPool.messageDialog]
    )

    SystemDialogView(dialogs: stream.dialogs, dialog: PreviewObjectPool.messageDialog)
}

#Preview("Text prompt") {
    @Previewable @State var stream = PreviewObjectPool.streamViewModel(
        phase: .streaming,
        dialogs: [PreviewObjectPool.keyboardDialog]
    )

    SystemDialogView(dialogs: stream.dialogs, dialog: PreviewObjectPool.keyboardDialog)
}
#endif

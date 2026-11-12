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
    @Bindable var stream: StreamViewModel

    let dialog: SystemDialogRequest

    var body: some View {
        switch dialog.kind {
        case .message(let title, let text, _, _, _):
            GameMessageDialog(
                title: title,
                text: text,
                buttons: stream.buttons(of: dialog),
                onAnswer: answer(buttonIndex:)
            )
        case .keyboard(_, let description, _, _):
            GameTextPrompt(
                text: $stream.dialogText,
                title: stream.textFieldTitle(of: dialog),
                description: description,
                onSubmit: submitText,
                onCancel: cancel
            )
        }
    }
}

private extension SystemDialogView {
    func answer(buttonIndex: Int) {
        stream.answer(dialog, buttonIndex: buttonIndex)
    }

    func submitText() {
        stream.submitText(for: dialog)
    }

    func cancel() {
        stream.cancel(dialog)
    }
}

#if DEBUG
#Preview("Message") {
    SystemDialogView(
        stream: PreviewObjectPool.streamViewModel(
            phase: .streaming,
            dialogs: [PreviewObjectPool.messageDialog]
        ),
        dialog: PreviewObjectPool.messageDialog
    )
}

#Preview("Text prompt") {
    SystemDialogView(
        stream: PreviewObjectPool.streamViewModel(
            phase: .streaming,
            dialogs: [PreviewObjectPool.keyboardDialog]
        ),
        dialog: PreviewObjectPool.keyboardDialog
    )
}
#endif

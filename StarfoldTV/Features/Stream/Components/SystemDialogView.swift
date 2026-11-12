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
    @Bindable var stream: StreamViewModel

    let dialog: SystemDialogRequest

    var body: some View {
        switch dialog.kind {
        case .message(let title, let text, _, _, _):
            GameMessageDialog(
                title: title,
                text: text,
                buttons: stream.buttons(of: dialog),
                onAnswer: { answer(buttonIndex: $0) },
                onCancel: { cancel() }
            )
        case .keyboard(_, let description, _, _):
            GameTextPrompt(
                text: $stream.dialogText,
                title: stream.textFieldTitle(of: dialog),
                description: description,
                onSubmit: { submitText() },
                onCancel: { cancel() }
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
#Preview("Game dialog", arguments: PreviewObjectPool.systemDialogs) { dialog in
    SystemDialogView(
        stream: PreviewObjectPool.streamViewModel(phase: .streaming, dialogs: [dialog]),
        dialog: dialog
    )
}
#endif

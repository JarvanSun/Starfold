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
    let dialog: SystemDialogRequest
    @Bindable var stream: StreamViewModel

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
                title: stream.textFieldTitle(of: dialog),
                description: description,
                text: $stream.dialogText,
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
@available(macOS 27, *)
#Preview("Game dialog", arguments: PreviewObjectPool.systemDialogs) { dialog in
    SystemDialogView(
        dialog: dialog,
        stream: PreviewObjectPool.streamViewModel(phase: .streaming, dialogs: [dialog])
    )
}
#endif

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
    @Bindable var dialogs: SystemDialogsViewModel

    let dialog: SystemDialogRequest

    var body: some View {
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
                text: $dialogs.text,
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
@available(macOS 27, *)
#Preview("Game dialog", arguments: PreviewObjectPool.systemDialogs) { dialog in
    @Previewable @State var stream = PreviewObjectPool.streamViewModel(
        phase: .streaming,
        dialogs: [dialog]
    )

    SystemDialogView(dialogs: stream.dialogs, dialog: dialog)
}
#endif

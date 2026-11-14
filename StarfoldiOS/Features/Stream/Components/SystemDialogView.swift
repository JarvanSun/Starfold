//
//  SystemDialogView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct SystemDialogView: View {
    let systemDialogsViewModel: SystemDialogsViewModel
    let dialog: SystemDialogRequest

    var body: some View {
        let draftText: Binding<String> = .init(
            get: { systemDialogsViewModel.text },
            set: { systemDialogsViewModel.changeText(to: $0) }
        )

        switch dialog.kind {
        case .message(let title, let text, _, _, _):
            GameMessageDialog(
                title: title,
                text: text,
                buttons: systemDialogsViewModel.buttons(of: dialog),
                onAnswer: { answer(buttonIndex: $0) }
            )
        case .keyboard(_, let description, _, _):
            GameTextPrompt(
                text: draftText,
                title: systemDialogsViewModel.textFieldTitle(of: dialog),
                description: description,
                onSubmit: { submitText() },
                onCancel: { cancel() }
            )
        }
    }

    private func answer(buttonIndex: Int) {
        systemDialogsViewModel.answer(dialog, buttonIndex: buttonIndex)
    }

    private func submitText() {
        systemDialogsViewModel.submitText(for: dialog)
    }

    private func cancel() {
        systemDialogsViewModel.cancel(dialog)
    }
}

#if DEBUG
@available(iOS 27, *)
#Preview("Game dialog", arguments: PreviewObjectPool.systemDialogs) { dialog in
    @Previewable @State var streamViewModel = PreviewObjectPool.streamViewModel(
        phase: .streaming,
        dialogs: [dialog]
    )

    SystemDialogView(systemDialogsViewModel: streamViewModel.dialogs, dialog: dialog)
}
#endif

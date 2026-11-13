//
//  SystemDialogsViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Observation
import StreamKit

@Observable
public final class SystemDialogsViewModel {
    public private(set) var text = ""
    public private(set) var queue: [SystemDialogRequest] = []

    private var connection: StreamConnection?
    private var draftedDialogID: String?

    public var presentedDialog: SystemDialogRequest? {
        queue.first
    }

    public func changeText(to newText: String) {
        text = String(newText.prefix(presentedDialog?.maxTextLength ?? newText.count))
    }

    public func answer(_ dialog: SystemDialogRequest, buttonIndex: Int) {
        remove(id: dialog.id)

        guard let connection else { return }

        Task { await connection.answerDialog(id: dialog.id, buttonIndex: buttonIndex) }
    }

    public func submitText(for dialog: SystemDialogRequest) {
        answerKeyboard(dialog, text: text)
    }

    public func cancel(_ dialog: SystemDialogRequest) {
        switch dialog.kind {
        case .message(_, _, _, _, let cancelIndex?): answer(dialog, buttonIndex: cancelIndex)
        case .message(_, _, _, _, nil): break
        case .keyboard: answerKeyboard(dialog, text: nil)
        }
    }

    private func answerKeyboard(_ dialog: SystemDialogRequest, text: String?) {
        remove(id: dialog.id)

        guard let connection else { return }

        Task { await connection.answerKeyboard(id: dialog.id, text: text) }
    }

    public func buttons(of dialog: SystemDialogRequest) -> [DialogButton] {
        switch dialog.kind {
        case .message(_, _, let titles, _, _) where titles.isEmpty: [acknowledgeButton]
        case .message(_, _, let titles, _, _):
            titles.enumerated().map { index, title in
                .init(index: index, title: title, role: dialog.role(ofButtonAt: index))
            }
        case .keyboard: []
        }
    }

    private var acknowledgeButton: DialogButton {
        .init(
            index: 0,
            title: String(localized: "stream.dialog.ok", bundle: .module),
            role: .primary
        )
    }

    public func textFieldTitle(of dialog: SystemDialogRequest) -> String {
        switch dialog.kind {
        case .keyboard(let title, _, _, _) where !title.isEmpty: title
        case .keyboard, .message:
            String(localized: "stream.dialog.textFieldTitle", bundle: .module)
        }
    }

    func attach(_ connection: StreamConnection) {
        self.connection = connection
    }

    func add(_ dialog: SystemDialogRequest) {
        queue.append(dialog)

        draftTextForPresentedDialog()
    }

    func remove(id: String) {
        queue.removeAll { $0.id == id }

        draftTextForPresentedDialog()
    }

    private func draftTextForPresentedDialog() {
        guard draftedDialogID != presentedDialog?.id else { return }

        draftedDialogID = presentedDialog?.id
        text = presentedDialog?.defaultText ?? ""
    }

}

private extension SystemDialogRequest {
    var defaultText: String {
        switch kind {
        case .keyboard(_, _, let defaultText, _): defaultText
        case .message: ""
        }
    }

    var maxTextLength: Int? {
        guard case .keyboard(_, _, _, let maxLength) = kind else { return nil }

        return maxLength
    }

    func role(ofButtonAt index: Int) -> DialogButtonRole {
        guard case .message(_, _, _, let defaultIndex, let cancelIndex) = kind else {
            return .plain
        }

        return switch (index == defaultIndex, index == cancelIndex) {
        case (true, _): .primary
        case (false, true): .cancel
        case (false, false): .plain
        }
    }
}

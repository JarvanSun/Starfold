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
    public var text = "" {
        didSet { limitText() }
    }

    public private(set) var queue: [SystemDialogRequest] = []

    private var connection: StreamConnection?
    private var draftedDialogID: String?

    public var presentedDialog: SystemDialogRequest? {
        queue.first
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

    public func buttons(of dialog: SystemDialogRequest) -> [DialogButton] {
        switch dialog.kind {
        case .message(_, _, let titles, _, _) where titles.isEmpty: [acknowledgeButton]
        case .message(_, _, let titles, let defaultIndex, let cancelIndex):
            titles.enumerated().map { index, title in
                .init(
                    index: index,
                    title: title,
                    role: role(
                        ofButtonAt: index,
                        defaultIndex: defaultIndex,
                        cancelIndex: cancelIndex
                    )
                )
            }
        case .keyboard: []
        }
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
}

private extension SystemDialogsViewModel {
    var acknowledgeButton: DialogButton {
        .init(
            index: 0,
            title: String(localized: "stream.dialog.ok", bundle: .module),
            role: .primary
        )
    }

    func draftTextForPresentedDialog() {
        guard draftedDialogID != presentedDialog?.id else { return }

        draftedDialogID = presentedDialog?.id
        text = presentedDialog.map(defaultText(of:)) ?? ""
    }

    func defaultText(of dialog: SystemDialogRequest) -> String {
        switch dialog.kind {
        case .keyboard(_, _, let defaultText, _): defaultText
        case .message: ""
        }
    }

    func limitText() {
        guard
            case .keyboard(_, _, _, let maxLength?) = presentedDialog?.kind,
            text.count > maxLength
        else {
            return
        }

        text = String(text.prefix(maxLength))
    }

    func answerKeyboard(_ dialog: SystemDialogRequest, text: String?) {
        remove(id: dialog.id)

        guard let connection else { return }

        Task { await connection.answerKeyboard(id: dialog.id, text: text) }
    }

    func role(ofButtonAt index: Int, defaultIndex: Int, cancelIndex: Int?) -> DialogButtonRole {
        switch (index == defaultIndex, index == cancelIndex) {
        case (true, _): .primary
        case (false, true): .cancel
        case (false, false): .plain
        }
    }
}

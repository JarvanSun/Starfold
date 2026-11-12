//
//  SystemDialogsViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import Testing

@testable import StarfoldShared

struct SystemDialogsViewModelTests {
    let message = SystemDialogRequest(
        id: "save",
        kind: .message(
            title: "Save?",
            text: "",
            buttons: ["Yes", "No"],
            defaultIndex: 0,
            cancelIndex: 1
        )
    )
    let notice = SystemDialogRequest(
        id: "notice",
        kind: .message(title: "Saved", text: "", buttons: [], defaultIndex: 0, cancelIndex: nil)
    )
    let textPrompt = SystemDialogRequest(
        id: "name",
        kind: .keyboard(title: "Name", description: "", defaultText: "Nova", maxLength: 8)
    )

    @Test
    func addThenPresentsTheFirstDialog() {
        // Given
        let dialogs = SystemDialogsViewModel()

        // When
        dialogs.add(message)
        dialogs.add(textPrompt)

        // Then
        #expect(dialogs.presentedDialog == message)
        #expect(dialogs.queue.map(\.id) == ["save", "name"])
    }

    @Test
    func answerThenRemovesTheDialog() {
        // Given
        let dialogs = makeDialogs(showing: message)

        // When
        dialogs.answer(message, buttonIndex: 0)

        // Then
        #expect(dialogs.queue.isEmpty)
    }

    @Test
    func removeWhenTheHostDismissesADialogThenPresentsTheNextOne() {
        // Given
        let dialogs = makeDialogs(showing: message)
        dialogs.add(textPrompt)

        // When
        dialogs.remove(id: message.id)

        // Then
        #expect(dialogs.presentedDialog == textPrompt)
        #expect(dialogs.text == "Nova")
    }

    @Test
    func buttonsOfAMessageThenMarkTheDefaultAndTheCancelButton() {
        // When
        let buttons = SystemDialogsViewModel().buttons(of: message)

        // Then
        #expect(buttons.map(\.title) == ["Yes", "No"])
        #expect(buttons.map(\.role) == [.primary, .cancel])
    }

    @Test
    func buttonsOfAMessageWithoutButtonsThenOfferOneToAcknowledge() {
        // When
        let buttons = SystemDialogsViewModel().buttons(of: notice)

        // Then
        #expect(buttons.map(\.index) == [0])
        #expect(buttons.map(\.role) == [.primary])
        #expect(buttons.first?.title.isEmpty == false)
    }

    @Test
    func keyboardDialogThenDraftsItsDefaultText() {
        #expect(makeDialogs(showing: textPrompt).text == "Nova")
    }

    @Test
    func changeTextLongerThanTheHostAllowsThenIsCutToTheLimit() {
        // Given
        let dialogs = makeDialogs(showing: textPrompt)

        // When
        dialogs.changeText(to: "Nova Squadron")

        // Then
        #expect(dialogs.text == "Nova Squ")
    }

    @Test
    func submitTextThenClosesTheDialogAndClearsTheDraft() {
        // Given
        let dialogs = makeDialogs(showing: textPrompt)

        // When
        dialogs.submitText(for: textPrompt)

        // Then
        #expect(dialogs.presentedDialog == nil)
        #expect(dialogs.text.isEmpty)
    }

    @Test
    func cancelThenClosesAMessageThatCanBeCancelled() {
        // Given
        let dialogs = makeDialogs(showing: message)

        // When
        dialogs.cancel(message)

        // Then
        #expect(dialogs.queue.isEmpty)
    }

    @Test
    func cancelWhenTheMessageHasNoCancelButtonThenKeepsIt() {
        // Given
        let dialogs = makeDialogs(showing: notice)

        // When
        dialogs.cancel(notice)

        // Then
        #expect(dialogs.queue == [notice])
    }

    @Test
    func textFieldTitleWhenTheGameGivesNoneThenIsNotEmpty() {
        // Given
        let dialogs = SystemDialogsViewModel()
        let untitled = SystemDialogRequest(
            id: "untitled",
            kind: .keyboard(title: "", description: "", defaultText: "", maxLength: nil)
        )

        // Then
        #expect(dialogs.textFieldTitle(of: textPrompt) == "Name")
        #expect(!dialogs.textFieldTitle(of: untitled).isEmpty)
    }
}

private extension SystemDialogsViewModelTests {
    func makeDialogs(showing dialog: SystemDialogRequest) -> SystemDialogsViewModel {
        let dialogs = SystemDialogsViewModel()

        dialogs.add(dialog)

        return dialogs
    }
}

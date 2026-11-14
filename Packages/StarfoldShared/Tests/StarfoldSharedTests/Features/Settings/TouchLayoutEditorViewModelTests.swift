//
//  TouchLayoutEditorViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import StreamKit
import Testing

@testable import StarfoldShared

struct TouchLayoutEditorViewModelTests {
    @Test
    func moveThenSelectsTheControlAndSavesItsOffset() throws {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        let leftStick = try control(.leftStick, in: editor)

        // When
        editor.move(leftStick, by: CGSize(width: 12, height: -8))
        editor.move(leftStick, by: CGSize(width: 20, height: -10))
        editor.endMove()

        // Then
        #expect(editor.selectedID == leftStick.id)
        let saved = preferences.touchLayoutAdjustments(for: .landscape)
        #expect(saved.adjustment(for: leftStick.id).offset == CGPoint(x: 20, y: -10))
    }

    @Test
    func selectedPlacementThenFindsTheSelectedControlInAPlan() throws {
        // Given
        let editor = TouchLayoutEditorViewModel(preferences: .init(defaults: .dummyEmpty))
        let a = try control(.button(.a), in: editor)
        editor.select(a)

        // When
        let selected = editor.selectedPlacement(in: editor.plan(for: .dummy, in: .landscape))

        // Then
        #expect(selected?.id == a.id)
    }

    @Test
    func planWhenTheOrientationIsNotShownYetThenUsesThatOrientationsEdits() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        var portrait = TouchLayoutAdjustments()
        portrait.opacity = 0.4
        preferences.setTouchLayoutAdjustments(portrait, for: .portrait)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)

        // When
        let plan = editor.plan(for: .dummy, in: .portrait)

        // Then
        #expect(plan.opacity == 0.4)
    }

    @Test
    func moveThenIsMovingUntilTheMoveEnds() throws {
        // Given
        let editor = TouchLayoutEditorViewModel(preferences: .init(defaults: .dummyEmpty))
        let a = try control(.button(.a), in: editor)

        // When
        editor.move(a, by: CGSize(width: 10, height: 0))

        // Then
        #expect(editor.isMoving)
        editor.endMove()
        #expect(!editor.isMoving)
    }

    @Test
    func moveWhenAnotherControlsDragNeverEndedThenStartsFromItsOwnOffset() throws {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        let leftStick = try control(.leftStick, in: editor)
        let a = try control(.button(.a), in: editor)
        editor.move(leftStick, by: CGSize(width: 40, height: 0))
        editor.endMove()
        editor.move(leftStick, by: CGSize(width: 5, height: 0))

        // When
        editor.move(a, by: CGSize(width: 0, height: -10))

        // Then
        let saved = preferences.touchLayoutAdjustments(for: .landscape)
        #expect(saved.adjustment(for: a.id).offset == CGPoint(x: 0, y: -10))
    }

    @Test
    func selectedScaleWhenChangedThenScalesOnlyTheSelectedControl() throws {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        let a = try control(.button(.a), in: editor)
        let y = try control(.button(.y), in: editor)
        editor.select(a)

        // When
        editor.selectedScale = 1.3

        // Then
        let saved = preferences.touchLayoutAdjustments(for: .landscape)
        #expect(saved.adjustment(for: a.id).scale == 1.3)
        #expect(saved.adjustment(for: y.id).scale == 1)
    }

    @Test
    func showWhenTheOrientationChangesThenEditsThatOrientationsLayout() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        editor.opacity = 0.5

        // When
        editor.show(.portrait)

        // Then
        #expect(editor.opacity == TouchLayoutAdjustments().opacity)
        #expect(preferences.touchLayoutAdjustments(for: .landscape).opacity == 0.5)
    }

    @Test
    func resetThenRestoresTheStandardLayout() throws {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        let leftStick = try control(.leftStick, in: editor)
        editor.move(leftStick, by: CGSize(width: 30, height: 0))
        editor.selectedStickVisibility = .off

        // When
        editor.reset()

        // Then
        #expect(preferences.touchLayoutAdjustments(for: .landscape) == TouchLayoutAdjustments())
        #expect(preferences.touchSticks == TouchSticks())
        #expect(!editor.hasSelection)
    }

    @Test
    func selectedStickVisibilityWhenChangedThenSavesItForThatStickOnly() throws {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        editor.select(try control(.rightStick, in: editor))

        // When
        editor.selectedStickVisibility = .onTouch

        // Then
        #expect(preferences.touchSticks.visibility(of: .rightStick) == .onTouch)
        #expect(preferences.touchSticks.visibility(of: .leftStick) == .always)
        #expect(
            editor.plan(for: .dummy, in: .landscape).sticks.visibility(of: .rightStick) == .onTouch
        )
    }

    @Test
    func selectedStickVisibilityWhenOffThenTheStickCannotBeResized() throws {
        // Given
        let editor = TouchLayoutEditorViewModel(preferences: .init(defaults: .dummyEmpty))
        editor.select(try control(.leftStick, in: editor))

        // When
        editor.selectedStickVisibility = .off

        // Then
        #expect(editor.isStickSelected)
        #expect(!editor.canResizeSelection)
    }

    @Test
    func selectWhenAButtonIsSelectedThenOffersNoStickVisibility() throws {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)

        // When
        editor.select(try control(.button(.a), in: editor))
        editor.selectedStickVisibility = .off

        // Then
        #expect(!editor.isStickSelected)
        #expect(editor.canResizeSelection)
        #expect(preferences.touchSticks == TouchSticks())
    }
}

private extension TouchLayoutEditorViewModelTests {
    func control(
        _ input: TouchInput,
        in editor: TouchLayoutEditorViewModel
    ) throws -> TouchControlPlacement {
        try #require(editor.plan(for: .dummy, in: .landscape).controls.first { $0.input == input })
    }
}

//
//  TouchLayoutEditorViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import Testing

@testable import StarfoldShared

struct TouchLayoutEditorViewModelTests {
    @Test
    func moveThenSelectsTheControlAndSavesItsOffset() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)

        // When
        editor.move("left.inner.0", by: CGSize(width: 12, height: -8))
        editor.move("left.inner.0", by: CGSize(width: 20, height: -10))
        editor.endMove()

        // Then
        #expect(editor.selectedID == "left.inner.0")
        let saved = preferences.touchLayoutAdjustments(for: .landscape)
        #expect(saved.adjustment(for: "left.inner.0").offset == CGPoint(x: 20, y: -10))
    }

    @Test
    func selectedScaleWhenChangedThenScalesOnlyTheSelectedControl() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        editor.select("right.inner.2")

        // When
        editor.selectedScale = 1.3

        // Then
        let saved = preferences.touchLayoutAdjustments(for: .landscape)
        #expect(saved.adjustment(for: "right.inner.2").scale == 1.3)
        #expect(saved.adjustment(for: "right.inner.0").scale == 1)
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
    func resetThenRestoresTheStandardLayout() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        editor.move("left.inner.0", by: CGSize(width: 30, height: 0))

        // When
        editor.reset()

        // Then
        #expect(preferences.touchLayoutAdjustments(for: .landscape) == TouchLayoutAdjustments())
        #expect(!editor.hasSelection)
    }
}

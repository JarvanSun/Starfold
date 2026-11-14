//
//  TouchControlsViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Observation
import StreamKit
import Synchronization
import Testing
import XboxKit

@testable import StarfoldShared

struct TouchControlsViewModelTests {
    @Test
    func isShowingWhenNothingHasHappenedThenShowsTheStandardLayout() {
        // Given / When
        let touch = makeTouchControls()

        // Then
        #expect(touch.isShowing)
        #expect(touch.reference == .standard)
        #expect(!touch.isShowingTitleLayout)
    }

    @Test
    func applyWhenTheGameHidesTheLayoutThenHidesIt() {
        // Given
        let touch = makeTouchControls()

        // When
        touch.apply(.hide)

        // Then
        #expect(!touch.isShowing)
    }

    @Test
    func applyWhenTheGameShowsALayoutAfterHidingThenShowsThatLayout() {
        // Given
        let touch = makeTouchControls()
        touch.apply(.hide)

        // When
        touch.apply(.showLayout(.named("driving"), statePatch: nil))

        // Then
        #expect(touch.isShowing)
        #expect(touch.reference == .named("driving"))
    }

    @Test
    func applyWhenTheGameAsksForItsLayoutWithoutABundleThenKeepsTheStandardLayout() {
        // Given
        let touch = makeTouchControls()

        // When
        touch.apply(.showLayout(.titleDefault, statePatch: Data("[]".utf8)))

        // Then
        #expect(!touch.isShowingTitleLayout)
        #expect(touch.plan(for: .dummy, in: .landscape).controls.count == 15)
    }

    @Test
    func loadWhenTheGamePatchedItsStateBeforeTheBundleArrivedThenKeepsThatState() throws {
        // Given
        let touch = makeTouchControls()
        touch.focus(onTitle: "1717")
        let patch = #"[{"op":"replace","path":"/showsWheel","value":false}]"#
        touch.apply(.showLayout(.titleDefault, statePatch: Data(patch.utf8)))

        // When
        touch.load(try .dummy(), forTitle: "1717")

        // Then
        #expect(touch.isShowingTitleLayout)
    }

    @Test
    func focusWhenAnotherTitleTakesFocusThenShowsTheStandardLayoutAgain() {
        // Given
        let touch = makeTouchControls()
        touch.focus(onTitle: "1717")
        touch.apply(.showLayout(.named("driving"), statePatch: nil))
        touch.apply(.hide)

        // When
        touch.focus(onTitle: "750c")

        // Then
        #expect(touch.isShowing)
        #expect(touch.reference == .standard)
        #expect(!touch.isShowingTitleLayout)
    }

    @Test
    func focusWhenATitleRegainsFocusThenRestoresItsLayoutAndState() throws {
        // Given
        let touch = makeTouchControls()
        touch.focus(onTitle: "1717")
        touch.load(try .dummy(), forTitle: "1717")
        touch.apply(.showLayout(.titleDefault, statePatch: .hidingTheWheel))
        touch.focus(onTitle: "750c")

        // When
        touch.focus(onTitle: "1717")

        // Then
        #expect(touch.reference == .titleDefault)
        #expect(touch.isShowingTitleLayout)
    }

    @Test
    func loadWhenTheBundleIsForATitleNoLongerFocusedThenKeepsItForThatTitle() throws {
        // Given
        let touch = makeTouchControls()
        touch.focus(onTitle: "1717")
        touch.apply(.showLayout(.titleDefault, statePatch: .hidingTheWheel))
        touch.focus(onTitle: "750c")

        // When
        touch.load(try .dummy(), forTitle: "1717")

        // Then
        #expect(!touch.isShowingTitleLayout)
        touch.focus(onTitle: "1717")
        #expect(touch.isShowingTitleLayout)
    }

    @Test
    func planWhenTheEditorChangesTheLayoutThenTellsObserversAtOnce() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let touch = makeTouchControls(preferences: preferences)
        let editor = TouchLayoutEditorViewModel(preferences: preferences)
        let didChange = Mutex(false)
        withObservationTracking {
            _ = touch.plan(for: .dummy, in: .landscape)
        } onChange: {
            didChange.withLock { $0 = true }
        }

        // When
        editor.opacity = 0.3

        // Then
        #expect(didChange.withLock { $0 })
        #expect(touch.plan(for: .dummy, in: .landscape).opacity == 0.3)
    }

    @Test
    func planWhenTheStandardLayoutIsAdjustedThenUsesThatOrientationsAdjustments() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        var adjustments = TouchLayoutAdjustments()
        adjustments.opacity = 0.4
        preferences.setTouchLayoutAdjustments(adjustments, for: .portrait)
        let touch = makeTouchControls(preferences: preferences)

        // When
        let portrait = touch.plan(for: .dummy, in: .portrait)
        let landscape = touch.plan(for: .dummy, in: .landscape)

        // Then
        #expect(portrait.opacity == 0.4)
        #expect(landscape.opacity == TouchLayoutAdjustments().opacity)
    }

    @Test
    func planWhenTheStandardLayoutIsShownThenUsesTheStickSettings() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.touchSticks.setVisibility(.onTouch, of: .leftStick)
        let touch = makeTouchControls(preferences: preferences)

        // When
        let plan = touch.plan(for: .dummy, in: .landscape)

        // Then
        #expect(plan.sticks.visibility(of: .leftStick) == .onTouch)
    }
}

private extension TouchControlsViewModelTests {
    func makeTouchControls(
        preferences: Preferences = .init(defaults: .dummyEmpty)
    ) -> TouchControlsViewModel {
        .init(
            controllers: ControllerHub(
                routing: .gated,
                touchControllerCategory: "Touch Controller"
            ),
            preferences: preferences
        )
    }
}

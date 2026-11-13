//
//  TouchControlsViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import Testing

@testable import StarfoldShared

struct TouchControlsViewModelTests {
    @Test
    func isShowingWhenNothingHasHappenedThenShowsTheStandardLayout() {
        // Given / When
        let touch = makeTouchControls()

        // Then
        #expect(touch.isShowing)
        #expect(touch.layout == .standard)
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
        #expect(touch.layout == .named("driving"))
    }
}

private extension TouchControlsViewModelTests {
    func makeTouchControls() -> TouchControlsViewModel {
        .init(
            controllers: ControllerHub(routing: .gated, touchControllerCategory: "Touch Controller")
        )
    }
}

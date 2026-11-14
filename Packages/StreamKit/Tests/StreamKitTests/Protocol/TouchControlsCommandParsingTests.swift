//
//  TouchControlsCommandParsingTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import StreamKit

struct TouchControlsCommandParsingTests {
    @Test
    func initWhenShowLayoutV2WithEmptyIDThenShowsStandardLayout() {
        // Given / When
        let command = TouchControlsCommand(
            target: .showTouchLayoutV2,
            object: ["layoutId": ""],
            text: #"{"layoutId":""}"#
        )

        // Then
        #expect(command == .showLayout(.standard, statePatch: nil))
    }

    @Test
    func initWhenShowLayoutV2WithPatchArrayThenCarriesPatchAsJSON() throws {
        // Given
        let patch: [[String: Any]] = [["op": "replace", "path": "/hp", "value": 3]]

        // When
        let command = TouchControlsCommand(
            target: .showTouchLayoutV2,
            object: ["layoutId": "driving", "patch": patch],
            text: nil
        )

        // Then
        let patchJSON = Data(#"[{"op":"replace","path":"/hp","value":3}]"#.utf8)
        #expect(command == .showLayout(.named("driving"), statePatch: patchJSON))
    }

    @Test
    func initWhenShowLayoutV2WithPatchStringThenCarriesItsBytes() {
        // Given
        let patch = #"[{"op":"remove","path":"/boost"}]"#

        // When
        let command = TouchControlsCommand(
            target: .showTouchLayoutV2,
            object: ["layoutId": "menu", "patch": patch],
            text: nil
        )

        // Then
        #expect(command == .showLayout(.named("menu"), statePatch: Data(patch.utf8)))
    }

    @Test(arguments: [
        ("driving", TouchLayoutReference.named("driving")),
        (#""flying""#, .named("flying")),
        ("", .standard),
    ])
    func initWhenShowLayoutWithRawIDThenShowsThatLayout(
        text: String,
        layout: TouchLayoutReference
    ) {
        // Given / When
        let command = TouchControlsCommand(target: .showTouchLayout, object: [:], text: text)

        // Then
        #expect(command == .showLayout(layout, statePatch: nil))
    }

    @Test
    func initWhenShowTitleDefaultThenShowsTheTitleDefaultLayout() {
        // Given / When
        let command = TouchControlsCommand(
            target: .showTitleDefaultTouchLayout,
            object: [:],
            text: "{}"
        )

        // Then
        #expect(command == .showLayout(.titleDefault, statePatch: nil))
    }

    @Test
    func initWhenPatchStateThenCarriesPatch() {
        // Given
        let patch: [[String: Any]] = [["op": "add", "path": "/ammo", "value": 12]]

        // When
        let command = TouchControlsCommand(
            target: .patchTouchLayoutState,
            object: ["patch": patch],
            text: nil
        )

        // Then
        #expect(command == .patchState(Data(#"[{"op":"add","path":"/ammo","value":12}]"#.utf8)))
    }

    @Test
    func initWhenPatchStateWithoutPatchThenIsNil() {
        // Given / When
        let command = TouchControlsCommand(
            target: .patchTouchLayoutState,
            object: [:],
            text: "{}"
        )

        // Then
        #expect(command == nil)
    }

    @Test
    func initWhenHideThenHides() {
        #expect(TouchControlsCommand(target: .hideTouchLayout, object: [:], text: nil) == .hide)
    }

    @Test
    func initWhenNotATouchControlsTargetThenIsNil() {
        #expect(TouchControlsCommand(target: .titleInfo, object: [:], text: nil) == nil)
    }
}

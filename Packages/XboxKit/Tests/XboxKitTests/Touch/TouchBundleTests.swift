//
//  TouchBundleTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct TouchBundleTests {
    @Test
    func initThenReadsTheMicrosoftSampleBundle() throws {
        // Given / When
        let bundle = try TouchBundle(archive: .dummySampleLayoutsBundle)

        // Then
        #expect(bundle.manifest.version == "1.1.0.0")
        #expect(bundle.manifest.defaultLayoutName == "standard-controller")
        #expect(
            bundle.layoutNames == [
                "driving", "fighting", "first-person-shooter", "platformer", "platformer-simple",
                "standard-controller",
            ]
        )
        #expect(bundle.context == TouchContext())
    }

    @Test
    func initWhenAnUnreadEntryCannotBeExpandedThenStillLoads() throws {
        // Given
        let manifest = #"{"defaultLayout":"main","layouts":"layouts","version":"1.0.0.0"}"#
        let entries = [
            ZipArchiveBuilder.Entry(name: "takxmanifest.json", contents: Data(manifest.utf8)),
            ZipArchiveBuilder.Entry(
                name: "layouts/neutral/main.json",
                contents: Data(menuLayout(.menu).utf8)
            ),
            ZipArchiveBuilder.Entry(
                name: "assets/neutral/@1.0x/Bow.png",
                contents: Data("bow".utf8),
                method: .bzip2
            ),
        ]

        // When
        let bundle = try TouchBundle(archive: ZipArchiveBuilder().archive(entries))

        // Then
        #expect(bundle.layoutNames == ["main"])
    }

    @Test
    func layoutThenDecodesASampleFileThatStartsWithAByteOrderMark() throws {
        // Given
        let bundle = try TouchBundle(archive: .dummySampleLayoutsBundle)

        // When
        let layout = try bundle.layout(named: "driving", locale: "en-US", context: bundle.context)

        // Then
        let wheel = try #require(layout.base.left.inner.first)
        guard case .control(let control) = wheel, case .joystick(let joystick) = control.kind else {
            Issue.record("Expected the steering joystick, got \(wheel)")
            return
        }
        #expect(joystick.axes.map(\.output) == [.gamepad(.leftJoystickX)])
        #expect(layout.base.lower.center.count == 1)
    }

    @Test(
        arguments: [
            ("en-US", TouchGamepadOutput.guide),
            ("en_US", .guide),
            ("EN-us", .guide),
            ("en-GB", .view),
            ("fr-FR", .menu),
        ]
    )
    func layoutThenPrefersTheLocaleThenItsLanguageThenNeutral(
        locale: String,
        expected: TouchGamepadOutput
    ) throws {
        // Given
        let bundle = try makeBundle([
            "layouts/neutral/main.json": menuLayout(.menu),
            "layouts/en/main.json": menuLayout(.view),
            "layouts/en-US/main.json": menuLayout(.guide),
        ])

        // When
        let layout = try bundle.layout(named: "main", locale: locale, context: .init())

        // Then
        #expect(firstUpperRightOutput(of: layout) == .gamepad(expected))
    }

    @Test
    func layoutWhenTheNameIsUnknownThenThrowsMissingLayout() throws {
        // Given
        let bundle = try makeBundle(["layouts/neutral/main.json": menuLayout(.menu)])

        // When / Then
        #expect(throws: TouchBundleError.missingLayout("other")) {
            try bundle.layout(named: "other", locale: "en-US", context: .init())
        }
    }

    @Test
    func layoutWhenTheFileIsNotJSONThenThrowsInvalidLayout() throws {
        // Given
        let bundle = try makeBundle(["layouts/neutral/main.json": "{"])

        // When
        let error = #expect(throws: TouchBundleError.self) {
            try bundle.layout(named: "main", locale: "en-US", context: .init())
        }

        // Then
        switch error {
        case .invalidLayout(name: "main", .malformedJSON)?: break
        default: Issue.record("Expected malformed JSON, got \(String(describing: error))")
        }
    }

    @Test
    func layoutThenReadsStateFromThePatchedContext() throws {
        // Given
        let bundle = try makeBundle([
            "context.json": .dummyLayeredContext,
            "layouts/neutral/layered.json": .dummyLayeredLayout,
        ])
        let patch = JSONPatch(operations: [
            .replace(path: try JSONPointer("/shieldImage"), value: .string("ShieldRaised"))
        ])
        let patched = try bundle.context.applying(patch)

        // When
        let original = try bundle.layout(named: "layered", locale: "en", context: bundle.context)
        let changed = try bundle.layout(named: "layered", locale: "en", context: patched)

        // Then
        #expect(shieldFaceImage(in: original) == .asset("ShieldIdle"))
        #expect(shieldFaceImage(in: changed) == .asset("ShieldRaised"))
    }
}

private extension TouchBundleTests {
    func makeBundle(_ files: [String: String]) throws -> TouchBundle {
        let manifest =
            #"{"defaultLayout":"main","layouts":"layouts","assets":"assets","version":"1.0.0.0"}"#
        let entries = (files.merging(["takxmanifest.json": manifest]) { file, _ in file })
            .sorted { $0.key < $1.key }
            .map { path, text in ZipArchiveBuilder.Entry(name: path, contents: Data(text.utf8)) }
        return try TouchBundle(archive: ZipArchiveBuilder().archive(entries))
    }

    func menuLayout(_ output: TouchGamepadOutput) -> String {
        #"{"content":{"upper":{"right":[{"type":"button","action":"\#(output.rawValue)"}]}}}"#
    }

    func firstUpperRightOutput(of layout: TouchLayout) -> TouchOutput? {
        guard case .control(let control)? = layout.base.upper.right.first,
            case .button(let button) = control.kind,
            case .output(let output)? = button.actions.first
        else { return nil }

        return output
    }

    func shieldFaceImage(in layout: TouchLayout) -> TouchImageSource? {
        guard case .control(let control)? = layout.base.right.inner.last else { return nil }

        return control.styles[.default]?.faceImage?.source
    }
}

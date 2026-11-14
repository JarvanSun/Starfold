//
//  XboxButtonSettingsTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import StreamKit

@MainActor
struct XboxButtonSettingsTests {
    @Test
    func setControllerConnectedWhenNoneIsConnectedThenOwnerIsUnknownWithoutReading() {
        // Given
        let (stub, settings) = makeSettings()

        // When
        settings.setControllerConnected(false)

        // Then
        #expect(settings.owner == .unknown)
        #expect(stub.readCount == 0)
    }

    @Test(arguments: [XboxButtonOwner.stream, .system, .unknown])
    func setControllerConnectedThenReadsTheOwner(_ expected: XboxButtonOwner) {
        // Given
        let (stub, settings) = makeSettings()
        stub.owner = expected

        // When
        settings.setControllerConnected(true)

        // Then
        #expect(settings.owner == expected)
    }

    @Test
    func setControllerConnectedWhenReadingFailsThenOwnerIsUnknown() {
        // Given
        let (stub, settings) = makeSettings()
        stub.isReadFailing = true

        // When
        settings.setControllerConnected(true)

        // Then
        #expect(settings.owner == .unknown)
    }

    @Test
    func setControllerConnectedWhenLastControllerLeavesThenForgetsTheOwner() {
        // Given
        let (_, settings) = makeSettings()
        settings.setControllerConnected(true)

        // When
        settings.setControllerConnected(false)

        // Then
        #expect(settings.owner == .unknown)
    }

    @Test
    func initWhenSettingsChangeWhileConnectedThenRereadsTheOwner() {
        // Given
        let (stub, settings) = makeSettings()
        settings.setControllerConnected(true)
        stub.owner = .stream

        // When
        stub.sendChange()

        // Then
        #expect(settings.owner == .stream)
    }

    @Test
    func openSettingsThenOpensTheSystemScreen() {
        // Given
        let (stub, settings) = makeSettings()

        // When
        settings.openSettings()

        // Then
        #expect(stub.openedSettingsCount == 1)
    }

    @Test
    func initWithoutSourceThenOwnerStaysUnknown() {
        // Given
        let settings = XboxButtonSettings(source: nil)

        // When
        settings.setControllerConnected(true)

        // Then
        #expect(settings.owner == .unknown)
    }
}

@MainActor
private extension XboxButtonSettingsTests {
    func makeSettings() -> (XboxButtonSettingsSourceStub, XboxButtonSettings) {
        let stub = XboxButtonSettingsSourceStub()
        return (stub, XboxButtonSettings(source: stub.source))
    }
}

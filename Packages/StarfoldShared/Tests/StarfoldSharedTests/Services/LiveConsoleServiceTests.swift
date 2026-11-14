//
//  LiveConsoleServiceTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing
import XboxKit

@testable import StarfoldShared

struct LiveConsoleServiceTests {
    @Test
    func consolesThenListsRemotePlayConsolesWithTheirState() async throws {
        // Given
        let (server, service) = try await makeService()
        server.installConsoles(
            """
            {"results":[
              {"serverId":"B","deviceName":"Living room","consoleType":"XboxSeriesX","powerState":"On"},
              {"serverId":"A","deviceName":"Bedroom","consoleType":"XboxSeriesS","powerState":"ConnectedStandby","wirelessWarning":true}]}
            """
        )

        // When
        let consoles = try await service.consoles()

        // Then
        #expect(consoles.map(\.name) == ["Living room", "Bedroom"])
        #expect(consoles.last?.hasWirelessWarning == true)
    }

    @Test
    func consolesWhenNoneHasRemotePlayThenListsEveryConsole() async throws {
        // Given
        let (server, service) = try await makeService()
        server.installConsoles(#"{"results":[]}"#)
        server.on(
            .consoleList,
            json:
                #"{"result":[{"id":"C","name":"Office","consoleType":"XboxOne","powerState":"Off"}]}"#
        )

        // When
        let consoles = try await service.consoles()

        // Then
        #expect(consoles.map(\.name) == ["Office"])
        #expect(consoles.first?.isReachable == false)
    }

    @Test
    func consolesWhenResponseIsUndecodableThenThrows() async throws {
        // Given
        let (server, service) = try await makeService()
        server.installConsoles("{}")

        // When / Then
        await #expect(throws: (any Error).self) { try await service.consoles() }
    }

    @Test
    func activityWhenPlayingThenNamesTheGame() async throws {
        // Given
        let (server, service) = try await makeService()
        server.on(.presence, json: .dummyPresencePlayingDiablo)
        server.on(.titleHistory, json: .dummyHistoryDiablo)

        // When
        let activity = try await service.activity()

        // Then
        #expect(activity?.kind == .playingNow)
        #expect(activity?.name == "Diablo IV")
    }

    @Test
    func sendWhenConsoleAcceptsCommandThenReturns() async throws {
        // Given
        let (server, service) = try await makeService()
        server.on(
            .consoleCommands,
            json: #"{"opId":"x","status":{"errorCode":"OK","errorMessage":null}}"#
        )

        // When / Then
        try await service.send(.turnOff, to: "X")
    }

    @Test
    func sendWhenConsoleTurnsCommandDownThenThrows() async throws {
        // Given
        let (server, service) = try await makeService()
        server.on(
            .consoleCommands,
            json: #"{"status":{"errorCode":"ConsoleNotConnected","errorMessage":null}}"#
        )

        // When / Then
        await #expect(throws: (any Error).self) { try await service.send(.turnOff, to: "X") }
    }

    @Test
    func sendWhenServiceRejectsCommandThenThrows() async throws {
        // Given
        let (server, service) = try await makeService()
        server.on(.consoleCommands, status: 403, json: "{}")

        // When / Then
        await #expect(throws: (any Error).self) { try await service.send(.turnOff, to: "X") }
    }
}

private extension LiveConsoleServiceTests {
    func makeService() async throws -> (XboxServerStub, LiveConsoleService) {
        let server = XboxServerStub()
        let account = try await server.signedInAccount()
        return (server, LiveConsoleService(xboxAccount: account, httpClient: server.client))
    }
}

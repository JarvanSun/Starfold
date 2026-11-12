//
//  XboxLiveClientTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct XboxLiveClientTests {
    @Test
    func consolesThenMapsIDsNamesAndPowerStates() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            .consoleList,
            json: """
                {"status":{"errorCode":"OK"},"result":[
                  {"id":"F400","name":"Living room","locale":"en-US","powerState":"ConnectedStandby","consoleType":"XboxSeriesS"},
                  {"id":"F401","name":"Old one","powerState":"Unknown-New-State"}],"agentUserId":null}
                """
        )
        let client = makeClient(server: server)

        // When
        let consoles = try await client.consoles()

        // Then
        #expect(consoles.map(\.id) == ["F400", "F401"])
        #expect(consoles[0].powerState == .connectedStandby)
        #expect(consoles[0].isReachable)
        #expect(consoles[1].powerState == .unknown)
        #expect(!consoles[1].isReachable)
    }

    @Test
    func consoleActivityWhenGameIsPlayingOnConsoleThenShowsItWithWideArt() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            .presence,
            json: """
                {"xuid":"2535","state":"Online","devices":[
                  {"type":"iOS","titles":[{"id":"100","name":"Phone Game","placement":"Full","state":"Active"}]},
                  {"type":"Scarlett","titles":[
                    {"id":"750323071","name":"Home","placement":"Background","state":"Active"},
                    {"id":"200","name":"Diablo IV","placement":"Full","state":"Active"}]}]}
                """
        )
        server.on(.titleHistory, json: .dummyTitleHistory)
        let client = makeClient(server: server)

        // When
        let activity = try #require(try await client.consoleActivity(xuid: "2535"))

        // Then
        #expect(activity.name == "Diablo IV")
        #expect(activity.kind == .playingNow)
        #expect(activity.imageURL?.absoluteString == "https://store-images.s-microsoft.com/hero")
    }

    @Test
    func consoleActivityWhenOnlyDashboardRunsThenIsNil() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            .presence,
            json: """
                {"xuid":"2535","state":"Online","devices":[
                  {"type":"Scarlett","titles":[{"id":"750323071","name":"Home","placement":"Full","state":"Active"}]}]}
                """
        )
        server.on(.titleHistory, json: .dummyTitleHistory)
        let client = makeClient(server: server)

        // When
        let activity = try await client.consoleActivity(xuid: "2535")

        // Then
        #expect(activity == nil)
    }

    @Test
    func sendWhenWakingUpThenPostsPowerCommandToConsole() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.consoleCommands, json: #"{"result":"OK"}"#)
        let client = makeClient(server: server)

        // When
        try await client.send(.wakeUp, to: "F400")

        // Then
        let request = try #require(server.requests.first)
        let body = try #require(
            request.body.flatMap { try JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        )
        #expect(request.method == "POST")
        #expect(request.headers["skillplatform"] == "RemoteManagement")
        #expect(request.headers["x-xbl-contract-version"] == "4")
        #expect(body["type"] as? String == "Power")
        #expect(body["command"] as? String == "WakeUp")
        #expect(body["linkedXboxId"] as? String == "F400")
    }

    @Test
    func sendWhenConsoleRejectsCommandThenThrowsErrorCode() async {
        // Given
        let server = XboxServerStub()
        server.on(
            .consoleCommands,
            json:
                #"{"result":null,"opId":"x","status":{"errorCode":"ConsoleNotConnected","errorMessage":"Offline"}}"#
        )
        let client = makeClient(server: server)

        // When / Then
        await #expect(
            throws: XboxLiveClient.CommandRejected(code: "ConsoleNotConnected", message: "Offline")
        ) {
            try await client.send(.turnOff, to: "F400")
        }
    }

    @Test
    func sendWhenConsoleAcceptsCommandThenReturns() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            .consoleCommands,
            json: #"{"result":null,"opId":"y","status":{"errorCode":"OK","errorMessage":null}}"#
        )
        let client = makeClient(server: server)

        // When / Then
        try await client.send(.turnOff, to: "F400")
    }
}

private extension XboxLiveClientTests {
    func makeClient(server: XboxServerStub) -> XboxLiveClient {
        .init(http: server.client) { "XBL3.0 x=1;t" }
    }
}

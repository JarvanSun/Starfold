//
//  ConsoleServiceStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

@testable import StarfoldShared

final class ConsoleServiceStub: ConsoleService {
    var listed: Result<[Console], Error> = .success([])
    var playing: Result<ConsoleActivity?, Error> = .success(nil)
    var commandResult: Result<Void, Error> = .success(())
    var isHanging = false
    var isCommandHanging = false
    private(set) var consoleReads = 0
    private(set) var sentCommands: [XboxLiveClient.PowerCommand] = []

    func consoles() async throws -> [Console] {
        consoleReads += 1

        if isHanging {
            try await Task.sleep(for: .seconds(3600))
        }

        return try listed.get()
    }

    func activity() async throws -> ConsoleActivity? {
        try playing.get()
    }

    func send(_ command: XboxLiveClient.PowerCommand, to consoleID: String) async throws {
        sentCommands.append(command)

        if isCommandHanging {
            try await Task.sleep(for: .seconds(3600))
        }

        try commandResult.get()
    }
}

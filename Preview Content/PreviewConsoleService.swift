//
//  PreviewConsoleService.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import XboxKit

struct PreviewConsoleService: ConsoleService {
    let reply: PreviewReply
    let listed: [Console]
    let playing: ConsoleActivity?

    func consoles() async throws -> [Console] {
        try await reply.answer(listed)
    }

    func activity() async throws -> ConsoleActivity? {
        try await reply.answer(playing)
    }

    func send(_ command: XboxLiveClient.PowerCommand, to consoleID: String) async throws {
        try await reply.answer(())
    }
}

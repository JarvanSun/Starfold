//
//  ConsoleService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

public protocol ConsoleService {
    func consoles() async throws -> [Console]
    func activity() async throws -> ConsoleActivity?
    func send(_ command: XboxLiveClient.PowerCommand, to consoleID: String) async throws
}

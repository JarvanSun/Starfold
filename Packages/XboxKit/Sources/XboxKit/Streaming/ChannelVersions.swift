//
//  ChannelVersions.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct ChannelVersions: Equatable, Sendable {
    public var chat: Int
    public var control: Int
    public var input: Int
    public var message: Int

    public init(chat: Int, control: Int, input: Int, message: Int) {
        self.chat = chat
        self.control = control
        self.input = input
        self.message = message
    }
}

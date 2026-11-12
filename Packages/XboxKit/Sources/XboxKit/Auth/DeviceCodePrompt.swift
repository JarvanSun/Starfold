//
//  DeviceCodePrompt.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct DeviceCodePrompt: Sendable, Equatable {
    public let userCode: String
    public let verificationURL: URL
    public let verificationURLComplete: URL
    let expiresAt: Date
    let deviceCode: String
    let pollInterval: Duration

    public init(
        userCode: String,
        verificationURL: URL,
        verificationURLComplete: URL,
        expiresAt: Date,
        deviceCode: String,
        pollInterval: Duration
    ) {
        self.userCode = userCode
        self.verificationURL = verificationURL
        self.verificationURLComplete = verificationURLComplete
        self.expiresAt = expiresAt
        self.deviceCode = deviceCode
        self.pollInterval = pollInterval
    }
}

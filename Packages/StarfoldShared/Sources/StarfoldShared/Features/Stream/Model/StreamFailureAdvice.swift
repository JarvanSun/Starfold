//
//  StreamFailureAdvice.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit

public enum StreamFailureAdvice: Equatable {
    case consoleOffline
    case remotePlayOff
    case consoleStillClosingLastStream
    case consoleNotAnswering
    case gameStillStarting
    case needsGamePass
    case networkDropped
    case unrecognized(String)

    public init(hostMessage message: String) {
        let isStartedTooSoon =
            message.contains("ServerStartStreaming") && message.contains("NotFound")

        switch message {
        case _ where message.contains("WaitingForServerToRegister"): self = .consoleOffline
        case _ where message.localizedCaseInsensitiveContains("disabled streaming"):
            self = .remotePlayOff
        case _ where isStartedTooSoon: self = .consoleStillClosingLastStream
        case "Timed out waiting for state": self = .consoleNotAnswering
        case _ where message.contains("DuplicateSessionRequest"): self = .gameStillStarting
        case _ where message.contains("HTTP 400"): self = .needsGamePass
        default: self = .unrecognized(message)
        }
    }

    init?(endReason: StreamEndReason) {
        switch endReason {
        case .failed(let message): self.init(hostMessage: message)
        case .connectionLost: self = .networkDropped
        case .userStopped, .hostEnded: return nil
        }
    }
}

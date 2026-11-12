//
//  StreamPhase.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum StreamPhase: Sendable, Equatable {
    case provisioning
    case queued(estimatedWait: Duration?)
    case connecting
    case streaming
    case ended(StreamEndReason)
}

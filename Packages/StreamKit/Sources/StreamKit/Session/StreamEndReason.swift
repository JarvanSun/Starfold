//
//  StreamEndReason.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

public enum StreamEndReason: Sendable, Equatable {
    case userStopped
    case leftApp
    case hostEnded
    case connectionLost
    case failed(String)

    init(failure error: Error) {
        let description =
            switch error {
            case GSSVSessionError.failed(let code, let message):
                [code, message].compactMap { $0 }.joined(separator: ": ")
            case GSSVSessionError.timedOut(let resource):
                "Timed out waiting for \(resource)"
            case let error as XboxHTTPError:
                error.hostCode.map { "HTTP \(error.statusCode) \($0)" }
                    ?? "HTTP \(error.statusCode)"
            default:
                error.localizedDescription
            }
        self = .failed(description)
    }
}

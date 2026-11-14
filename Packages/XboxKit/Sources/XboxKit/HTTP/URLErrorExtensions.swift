//
//  URLErrorExtensions.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/14.
//

import Foundation

extension URLError {
    var isConnectionInterruption: Bool {
        switch code {
        case .networkConnectionLost, .notConnectedToInternet, .timedOut, .cannotConnectToHost,
            .cannotFindHost, .dnsLookupFailed:
            true
        default:
            false
        }
    }
}

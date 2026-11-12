//
//  StreamError.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum StreamError: Error, Sendable, Equatable {
    case webRTC(String)
    case connectionTimedOut
}

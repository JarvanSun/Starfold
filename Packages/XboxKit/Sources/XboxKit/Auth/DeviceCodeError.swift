//
//  DeviceCodeError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum DeviceCodeError: Error, Sendable, Equatable {
    case expired
    case declined
    case server(code: String, description: String)
}

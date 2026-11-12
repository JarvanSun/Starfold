//
//  StreamQuality.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum StreamQuality: String, Codable, Sendable, CaseIterable {
    case standard
    case high
    case highest

    var operatingSystemName: String {
        switch self {
        case .standard: "android"
        case .high: "windows"
        case .highest: "tizen"
        }
    }
}

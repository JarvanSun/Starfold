//
//  InputReportType.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum InputReportType: UInt16 {
    case metadata = 1
    case gamepad = 2
    case clientMetadata = 8
    case serverMetadata = 16
    case vibration = 128

    func isPresent(in flags: UInt16) -> Bool {
        flags & rawValue != 0
    }
}

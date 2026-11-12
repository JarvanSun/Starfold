//
//  ConsoleStatusPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension ConsoleStatus {
    public var color: Color {
        switch self {
        case .on: .online
        case .standby: .standby
        case .unreachable: .standby.opacity(0.4)
        }
    }

    public var isPulsing: Bool {
        switch self {
        case .on: true
        case .standby, .unreachable: false
        }
    }
}

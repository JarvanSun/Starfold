//
//  ConsoleStatus.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

public enum ConsoleStatus {
    case on
    case standby
    case unreachable

    init(console: Console) {
        switch (console.powerState, console.isReachable) {
        case (.on, _): self = .on
        case (_, true): self = .standby
        case (_, false): self = .unreachable
        }
    }
}

//
//  ClockStub.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Synchronization

final class ClockStub: Sendable {
    private let current: Mutex<Date>

    var now: Date {
        current.withLock { $0 }
    }

    var nowProvider: @Sendable () -> Date {
        { [self] in now }
    }

    init(start: Date = .dummyTestStart) {
        current = Mutex(start)
    }

    func advance(_ seconds: TimeInterval) {
        current.withLock { $0 += seconds }
    }
}

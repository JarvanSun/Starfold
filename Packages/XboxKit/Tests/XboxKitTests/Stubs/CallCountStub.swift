//
//  CallCountStub.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Synchronization

final class CallCountStub: Sendable {
    private let count = Mutex(0)

    var callCount: Int {
        count.withLock { $0 }
    }

    func record() {
        count.withLock { $0 += 1 }
    }
}

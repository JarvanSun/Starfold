//
//  QueueEstimateStub.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Synchronization

final class QueueEstimateStub: Sendable {
    private let recorded = Mutex<[Duration?]>([])

    var estimates: [Duration?] {
        recorded.withLock { $0 }
    }

    func record(_ estimate: Duration?) {
        recorded.withLock { $0.append(estimate) }
    }
}

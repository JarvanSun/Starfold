//
//  ActiveInputHandlerStub.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

@testable import StreamKit

final class ActiveInputHandlerStub: @unchecked Sendable {
    private let lock = NSLock()

    private var changes: [ActiveInput] = []

    var recordedChanges: [ActiveInput] {
        lock.withLock { changes }
    }

    func record(_ input: ActiveInput) {
        lock.withLock { changes.append(input) }
    }
}

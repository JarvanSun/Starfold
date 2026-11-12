//
//  InMemorySecretStore.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Synchronization

public final class InMemorySecretStore: SecretStoring {
    private let secrets = Mutex<[String: Data]>([:])

    public init() {}

    public func read(_ key: String) throws -> Data? {
        secrets.withLock { $0[key] }
    }

    public func write(_ secret: Data, for key: String) throws {
        secrets.withLock { $0[key] = secret }
    }

    public func delete(_ key: String) throws {
        _ = secrets.withLock { $0.removeValue(forKey: key) }
    }

    public func allKeys() throws -> [String] {
        secrets.withLock { Array($0.keys) }
    }
}

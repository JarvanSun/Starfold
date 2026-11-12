//
//  SecretStoring.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public protocol SecretStoring: Sendable {
    func read(_ key: String) throws -> Data?
    func write(_ secret: Data, for key: String) throws
    func delete(_ key: String) throws
    func allKeys() throws -> [String]
}

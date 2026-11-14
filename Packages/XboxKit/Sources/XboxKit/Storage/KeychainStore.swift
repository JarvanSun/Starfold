//
//  KeychainStore.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import Security

public struct KeychainStore: SecretStoring {
    private let keychainService: String

    public init(keychainService: String) {
        self.keychainService = keychainService
    }

    public func read(_ key: String) throws -> Data? {
        var query = itemQuery(account: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess: return result as? Data
        case errSecItemNotFound: return nil
        default: throw KeychainError(status: status)
        }
    }

    public func write(_ secret: Data, for key: String) throws {
        let attributes: [String: Any] = [
            kSecValueData as String: secret,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        let status = SecItemUpdate(
            itemQuery(account: key) as CFDictionary,
            attributes as CFDictionary
        )

        switch status {
        case errSecSuccess: break
        case errSecItemNotFound: try addItem(account: key, attributes: attributes)
        default: throw KeychainError(status: status)
        }
    }

    private func addItem(account: String, attributes: [String: Any]) throws {
        let item = itemQuery(account: account).merging(attributes) { _, new in new }
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
    }

    private func itemQuery(account: String?) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
        ]

        if usesDataProtectionKeychain {
            query[kSecUseDataProtectionKeychain as String] = true
        }

        if let account {
            query[kSecAttrAccount as String] = account
        }

        return query
    }

    public func delete(_ key: String) throws {
        let status = SecItemDelete(itemQuery(account: key) as CFDictionary)

        switch status {
        case errSecSuccess, errSecItemNotFound: break
        default: throw KeychainError(status: status)
        }
    }

    public func allKeys() throws -> [String] {
        var query = itemQuery(account: nil)
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitAll

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess: return accounts(in: result)
        case errSecItemNotFound: return []
        default: throw KeychainError(status: status)
        }
    }

    private func accounts(in result: CFTypeRef?) -> [String] {
        let items = result as? [[String: Any]] ?? []
        return items.compactMap { $0[kSecAttrAccount as String] as? String }
    }
}

private extension KeychainStore {
    #if os(macOS)
    var usesDataProtectionKeychain: Bool { false }
    #else
    var usesDataProtectionKeychain: Bool { true }
    #endif
}

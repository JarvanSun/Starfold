//
//  CloudTitle.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct CloudTitle: Codable, Sendable, Hashable, Identifiable {
    public var id: String
    public var productID: String

    var hasEntitlement: Bool
    var isFreeInStore: Bool
    var supportedInputTypes: [String]
    var lastPlayed: Date?
    var userSubscriptions: [String]

    public var isPlayable: Bool {
        hasEntitlement || isFreeInStore
    }

    public var isGrantedBySubscription: Bool {
        !userSubscriptions.isEmpty
    }

    public var supportsTouch: Bool {
        supportedInputTypes.contains("NativeTouch")
    }

    public var supportsMouseAndKeyboard: Bool {
        supportedInputTypes.contains("MKB")
    }

    public init(
        id: String,
        productID: String,
        hasEntitlement: Bool,
        isFreeInStore: Bool,
        supportedInputTypes: [String],
        lastPlayed: Date? = nil,
        userSubscriptions: [String] = []
    ) {
        self.id = id
        self.productID = productID
        self.hasEntitlement = hasEntitlement
        self.isFreeInStore = isFreeInStore
        self.supportedInputTypes = supportedInputTypes
        self.lastPlayed = lastPlayed
        self.userSubscriptions = userSubscriptions
    }
}

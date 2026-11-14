//
//  CloudTitle.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct CloudTitle: Codable, Sendable, Hashable, Identifiable {
    private enum CodingKeys: String, CodingKey {
        case id
        case productID
        case touchBundleIDs
        case hasEntitlement
        case isFreeInStore
        case supportedInputTypes
        case lastPlayed
        case userSubscriptions
    }

    public var id: String
    public var productID: String
    public var touchBundleIDs: [String]

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
        let touchInputTypes: Set<TitleInputType> = [.nativeTouch, .customTouchOverlay]
        let hasTouchInput = supportedInputTypes.contains {
            touchInputTypes.contains(.init(name: $0))
        }
        return hasTouchInput || !touchBundleIDs.isEmpty
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
        touchBundleIDs: [String] = [],
        lastPlayed: Date? = nil,
        userSubscriptions: [String] = []
    ) {
        self.id = id
        self.productID = productID
        self.touchBundleIDs = touchBundleIDs
        self.hasEntitlement = hasEntitlement
        self.isFreeInStore = isFreeInStore
        self.supportedInputTypes = supportedInputTypes
        self.lastPlayed = lastPlayed
        self.userSubscriptions = userSubscriptions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        productID = try container.decode(String.self, forKey: .productID)
        touchBundleIDs = try container.decodeIfPresent([String].self, forKey: .touchBundleIDs) ?? []
        hasEntitlement = try container.decode(Bool.self, forKey: .hasEntitlement)
        isFreeInStore = try container.decode(Bool.self, forKey: .isFreeInStore)
        supportedInputTypes = try container.decode([String].self, forKey: .supportedInputTypes)
        lastPlayed = try container.decodeIfPresent(Date.self, forKey: .lastPlayed)
        userSubscriptions = try container.decode([String].self, forKey: .userSubscriptions)
    }
}

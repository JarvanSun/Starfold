//
//  Console.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct Console: Codable, Sendable, Hashable, Identifiable {
    public enum PowerState: String, Codable, Sendable {
        case on = "On"
        case connectedStandby = "ConnectedStandby"
        case off = "Off"
        case unknown

        public init(from decoder: Decoder) throws {
            let rawState = try decoder.singleValueContainer().decode(String.self)
            self = PowerState(rawValue: rawState) ?? .unknown
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case consoleType
        case powerState
        case hasOutOfHomeWarning = "outOfHomeWarning"
        case hasWirelessWarning = "wirelessWarning"
    }

    public var id: String
    public var name: String
    public var consoleType: String
    public var powerState: PowerState
    var hasOutOfHomeWarning: Bool
    public var hasWirelessWarning: Bool

    public var isReachable: Bool {
        powerState == .on || powerState == .connectedStandby
    }

    public init(
        id: String,
        name: String,
        consoleType: String,
        powerState: PowerState,
        hasOutOfHomeWarning: Bool = false,
        hasWirelessWarning: Bool = false
    ) {
        self.id = id
        self.name = name
        self.consoleType = consoleType
        self.powerState = powerState
        self.hasOutOfHomeWarning = hasOutOfHomeWarning
        self.hasWirelessWarning = hasWirelessWarning
    }
}

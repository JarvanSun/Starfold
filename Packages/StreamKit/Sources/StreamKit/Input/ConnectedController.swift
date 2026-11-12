//
//  ConnectedController.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct ConnectedController: Identifiable, Equatable, Sendable {
    public let id: ObjectIdentifier
    public var slot: UInt8
    public var name: String
    public var batteryLevel: Float?

    public init(id: ObjectIdentifier, slot: UInt8, name: String, batteryLevel: Float?) {
        self.id = id
        self.slot = slot
        self.name = name
        self.batteryLevel = batteryLevel
    }
}

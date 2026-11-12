//
//  GamepadButtons.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

struct GamepadButtons: Hashable, Sendable {
    private(set) var rawValue: UInt16

    init() {
        rawValue = 0
    }

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension GamepadButtons: SetAlgebra {
    func contains(_ member: GamepadButton) -> Bool {
        rawValue & member.rawValue != 0
    }

    func union(_ other: GamepadButtons) -> GamepadButtons {
        .init(rawValue: rawValue | other.rawValue)
    }

    func intersection(_ other: GamepadButtons) -> GamepadButtons {
        .init(rawValue: rawValue & other.rawValue)
    }

    func symmetricDifference(_ other: GamepadButtons) -> GamepadButtons {
        .init(rawValue: rawValue ^ other.rawValue)
    }

    @discardableResult
    mutating func insert(
        _ newMember: GamepadButton
    ) -> (inserted: Bool, memberAfterInsert: GamepadButton) {
        let wasMember = contains(newMember)

        rawValue |= newMember.rawValue

        return (!wasMember, newMember)
    }

    @discardableResult
    mutating func remove(_ member: GamepadButton) -> GamepadButton? {
        guard contains(member) else { return nil }

        rawValue &= ~member.rawValue

        return member
    }

    @discardableResult
    mutating func update(with newMember: GamepadButton) -> GamepadButton? {
        let wasMember = contains(newMember)

        rawValue |= newMember.rawValue

        return wasMember ? newMember : nil
    }

    mutating func formUnion(_ other: GamepadButtons) {
        rawValue |= other.rawValue
    }

    mutating func formIntersection(_ other: GamepadButtons) {
        rawValue &= other.rawValue
    }

    mutating func formSymmetricDifference(_ other: GamepadButtons) {
        rawValue ^= other.rawValue
    }
}

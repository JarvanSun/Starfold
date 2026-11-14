//
//  GamepadStatePhysicality.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

extension GamepadState {
    var physicality: GamepadPhysicality {
        mergedPhysicality ?? .init(physical: engagedControlFlags, virtual: 0)
    }

    var engagedControlFlags: UInt32 {
        let analogFlags: [(UInt32, Bool)] = [
            (0x10000, leftTrigger > 0),
            (0x20000, rightTrigger > 0),
            (0x40000, leftStick.x != 0),
            (0x80000, leftStick.y != 0),
            (0x100000, rightStick.x != 0),
            (0x200000, rightStick.y != 0),
        ]
        let buttonFlags = GamepadButton.allCases
            .filter { buttons.contains($0) }
            .reduce(UInt32(0)) { $0 | $1.physicalityFlag }
        return analogFlags.filter(\.1).reduce(buttonFlags) { $0 | $1.0 }
    }
}

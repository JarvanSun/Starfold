//
//  KeyBinding.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct KeyBinding: Sendable {
    public let key: KeyboardKey
    public let control: GamepadControl

    public init(key: KeyboardKey, control: GamepadControl) {
        self.key = key
        self.control = control
    }
}

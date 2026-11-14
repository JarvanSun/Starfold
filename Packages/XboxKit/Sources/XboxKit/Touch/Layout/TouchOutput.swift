//
//  TouchOutput.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchOutput: Sendable, Hashable, Decodable {
    case gamepad(TouchGamepadOutput)
    case relativeMouse(TouchMouseOutput)
    case unsupported(String)

    public init(name: String) {
        switch (TouchGamepadOutput(rawValue: name), TouchMouseOutput(rawValue: name)) {
        case (let gamepad?, _): self = .gamepad(gamepad)
        case (nil, let mouse?): self = .relativeMouse(mouse)
        case (nil, nil): self = .unsupported(name)
        }
    }

    public init(from decoder: Decoder) throws {
        self.init(name: try decoder.singleValueContainer().decode(String.self))
    }
}

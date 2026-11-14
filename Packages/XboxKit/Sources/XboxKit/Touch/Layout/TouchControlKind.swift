//
//  TouchControlKind.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchControlKind: Sendable, Hashable {
    private enum ControlType: String {
        case button
        case joystick
        case directionalPad
        case throttle
        case touchpad
        case arcadeButtons
        case blank
    }

    case button(TouchButton)
    case joystick(TouchJoystick)
    case directionalPad(TouchDirectionalPad)
    case throttle(TouchThrottle)
    case touchpad(Touchpad)
    case arcadeButtons(TouchArcadeButtons)
    case blank
    case unsupported(type: String)

    init(type: String, decoder: Decoder) {
        do {
            switch ControlType(rawValue: type) {
            case .button: self = .button(try .init(from: decoder))
            case .joystick: self = .joystick(try .init(from: decoder))
            case .directionalPad: self = .directionalPad(try .init(from: decoder))
            case .throttle: self = .throttle(try .init(from: decoder))
            case .touchpad: self = .touchpad(try .init(from: decoder))
            case .arcadeButtons: self = .arcadeButtons(try .init(from: decoder))
            case .blank: self = .blank
            case nil: self = .unsupported(type: type)
            }
        } catch {
            self = .unsupported(type: type)
        }
    }
}

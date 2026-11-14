//
//  TouchSticks.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchSticks: Hashable, Sendable, Codable {
    var left: TouchStickVisibility = .always
    var right: TouchStickVisibility = .always

    public func visibility(of input: TouchInput) -> TouchStickVisibility {
        switch input {
        case .leftStick: left
        case .rightStick: right
        case .button, .leftTrigger, .rightTrigger, .directionPad: .always
        }
    }

    mutating func setVisibility(_ visibility: TouchStickVisibility, of input: TouchInput) {
        switch input {
        case .leftStick: left = visibility
        case .rightStick: right = visibility
        case .button, .leftTrigger, .rightTrigger, .directionPad: return
        }
    }
}

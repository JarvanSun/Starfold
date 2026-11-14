//
//  TouchMouseOutput.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchMouseOutput: String, Sendable, Hashable, CaseIterable {
    case movement = "relativeMouse"
    case horizontal = "relativeMouseX"
    case vertical = "relativeMouseY"
    case up = "relativeMouseUp"
    case down = "relativeMouseDown"
    case left = "relativeMouseLeft"
    case right = "relativeMouseRight"
}

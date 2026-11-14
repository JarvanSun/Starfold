//
//  TouchStyleState.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchStyleState: String, Sendable, Hashable, CaseIterable {
    case `default`
    case idle
    case activated
    case disabled
    case toggled
    case pulled
    case moving
    case idleUp
    case activatedUp
    case activatedDown
}

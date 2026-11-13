//
//  TouchLayoutAdjustments.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

struct TouchLayoutAdjustments: Codable, Hashable, Sendable {
    var controls: [String: TouchControlAdjustment] = [:]
    var opacity: Double = 0.85

    func adjustment(for id: String) -> TouchControlAdjustment {
        controls[id] ?? .init()
    }
}

//
//  TouchJoystick.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchJoystick: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case axis
        case action
        case actionThreshold
        case legacyThreshold = "threshold"
        case isRelative = "relative"
        case shouldExpand = "expand"
    }

    public var axes: [TouchAxisMapping]
    public var actions: [TouchAction]
    public var actionThreshold: Double
    public var isRelative: Bool
    public var shouldExpand: Bool

    public init(
        axes: [TouchAxisMapping],
        actions: [TouchAction] = [],
        actionThreshold: Double = 0,
        isRelative: Bool = true,
        shouldExpand: Bool = true
    ) {
        self.axes = axes
        self.actions = actions
        self.actionThreshold = actionThreshold
        self.isRelative = isRelative
        self.shouldExpand = shouldExpand
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let axes = try container.decode(OneOrMany<TouchAxisMapping>.self, forKey: .axis).elements
        let actions = try container.decodeIfPresent(OneOrMany<TouchAction>.self, forKey: .action)
        let threshold =
            try container.decodeIfPresent(Double.self, forKey: .actionThreshold)
            ?? container.decodeIfPresent(Double.self, forKey: .legacyThreshold)
        let defaults = TouchJoystick(axes: axes)

        self.axes = axes
        self.actions = actions?.elements ?? defaults.actions
        actionThreshold = threshold ?? defaults.actionThreshold
        isRelative =
            try container.decodeIfPresent(Bool.self, forKey: .isRelative) ?? defaults.isRelative
        shouldExpand =
            try container.decodeIfPresent(Bool.self, forKey: .shouldExpand) ?? defaults.shouldExpand
    }
}

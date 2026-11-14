//
//  TouchArcadeButton.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchArcadeButton: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case action
        case isVisible = "visible"
        case isEnabled = "enabled"
    }

    public var actions: [TouchAction]
    public var isVisible: Bool
    public var isEnabled: Bool
    public var styles: [TouchStyleState: TouchControlStyle]

    public init(
        actions: [TouchAction],
        isVisible: Bool = true,
        isEnabled: Bool = true,
        styles: [TouchStyleState: TouchControlStyle] = [:]
    ) {
        self.actions = actions
        self.isVisible = isVisible
        self.isEnabled = isEnabled
        self.styles = styles
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions = try container.decode(OneOrMany<TouchAction>.self, forKey: .action).elements
        let defaults = TouchArcadeButton(actions: actions)

        self.actions = actions
        isVisible =
            try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? defaults.isVisible
        isEnabled =
            try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? defaults.isEnabled
        styles = try TouchStyleFields(from: decoder).styles
    }
}

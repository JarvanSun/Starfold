//
//  TouchButton.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchButton: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case action
        case pullAction
        case isToggle = "toggle"
    }

    public var actions: [TouchAction]
    public var pullAction: TouchPullAction?
    public var isToggle: Bool

    public init(actions: [TouchAction], pullAction: TouchPullAction? = nil, isToggle: Bool = false)
    {
        self.actions = actions
        self.pullAction = pullAction
        self.isToggle = isToggle
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions = try container.decode(OneOrMany<TouchAction>.self, forKey: .action).elements
        let defaults = TouchButton(actions: actions)

        self.actions = actions
        pullAction = try container.decodeIfPresent(TouchPullAction.self, forKey: .pullAction)
        isToggle = try container.decodeIfPresent(Bool.self, forKey: .isToggle) ?? defaults.isToggle
    }
}

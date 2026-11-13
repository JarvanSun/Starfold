//
//  Touchpad.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct Touchpad: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case axis
        case action
        case isRenderedAsButton = "renderAsButton"
    }

    public var axes: [TouchAxisMapping]
    public var actions: [TouchAction]
    public var isRenderedAsButton: Bool

    public init(
        axes: [TouchAxisMapping],
        actions: [TouchAction] = [],
        isRenderedAsButton: Bool = false
    ) {
        self.axes = axes
        self.actions = actions
        self.isRenderedAsButton = isRenderedAsButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let axes = try container.decode(OneOrMany<TouchAxisMapping>.self, forKey: .axis).elements
        let actions = try container.decodeIfPresent(OneOrMany<TouchAction>.self, forKey: .action)
        let defaults = Touchpad(axes: axes)

        self.axes = axes
        self.actions = actions?.elements ?? defaults.actions
        isRenderedAsButton =
            try container.decodeIfPresent(Bool.self, forKey: .isRenderedAsButton)
            ?? defaults.isRenderedAsButton
    }
}

//
//  TouchArcadeButtons.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchArcadeButtons: Sendable, Hashable, Decodable {
    private struct PositionKey: CodingKey {
        let stringValue: String
        let intValue: Int? = nil

        init(_ position: TouchArcadeButtonPosition) {
            stringValue = position.rawValue
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            nil
        }
    }

    public var buttons: [TouchArcadeButtonPosition: TouchArcadeButton]

    public init(buttons: [TouchArcadeButtonPosition: TouchArcadeButton]) {
        self.buttons = buttons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PositionKey.self)
        var buttons: [TouchArcadeButtonPosition: TouchArcadeButton] = [:]

        for position in TouchArcadeButtonPosition.allCases {
            buttons[position] = try container.decodeIfPresent(
                TouchArcadeButton.self,
                forKey: PositionKey(position)
            )
        }

        self.buttons = buttons
    }
}

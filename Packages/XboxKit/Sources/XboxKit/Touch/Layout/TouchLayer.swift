//
//  TouchLayer.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchLayer: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case left
        case right
        case center
        case upper
        case lower
        case sensors
    }

    public var left: TouchWheel
    public var right: TouchWheel
    public var center: TouchWheel
    public var upper: TouchEdge
    public var lower: TouchEdge
    public var sensors: [TouchSensor?]

    public init(
        left: TouchWheel = .init(),
        right: TouchWheel = .init(),
        center: TouchWheel = .init(),
        upper: TouchEdge = .init(),
        lower: TouchEdge = .init(),
        sensors: [TouchSensor?] = []
    ) {
        self.left = left
        self.right = right
        self.center = center
        self.upper = upper
        self.lower = lower
        self.sensors = sensors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = TouchLayer()

        left = try container.decodeIfPresent(TouchWheel.self, forKey: .left) ?? defaults.left
        right = try container.decodeIfPresent(TouchWheel.self, forKey: .right) ?? defaults.right
        center = try container.decodeIfPresent(TouchWheel.self, forKey: .center) ?? defaults.center
        upper = try container.decodeIfPresent(TouchEdge.self, forKey: .upper) ?? defaults.upper
        lower = try container.decodeIfPresent(TouchEdge.self, forKey: .lower) ?? defaults.lower
        sensors =
            try container.decodeIfPresent([TouchSensor?].self, forKey: .sensors) ?? defaults.sensors
    }
}

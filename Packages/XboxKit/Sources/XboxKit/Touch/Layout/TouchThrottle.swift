//
//  TouchThrottle.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchThrottle: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case upOutput = "axisUp"
        case downOutput = "axisDown"
        case isSticky = "sticky"
        case isRelative = "relative"
    }

    public var upOutput: TouchOutput
    public var downOutput: TouchOutput
    public var isSticky: Bool
    public var isRelative: Bool

    public init(
        upOutput: TouchOutput,
        downOutput: TouchOutput,
        isSticky: Bool = false,
        isRelative: Bool = true
    ) {
        self.upOutput = upOutput
        self.downOutput = downOutput
        self.isSticky = isSticky
        self.isRelative = isRelative
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let upOutput = try container.decode(TouchOutput.self, forKey: .upOutput)
        let downOutput = try container.decode(TouchOutput.self, forKey: .downOutput)
        let defaults = TouchThrottle(upOutput: upOutput, downOutput: downOutput)

        self.upOutput = upOutput
        self.downOutput = downOutput
        isSticky = try container.decodeIfPresent(Bool.self, forKey: .isSticky) ?? defaults.isSticky
        isRelative =
            try container.decodeIfPresent(Bool.self, forKey: .isRelative) ?? defaults.isRelative
    }
}

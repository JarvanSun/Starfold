//
//  TouchDirectionalPad.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchDirectionalPad: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case interaction
        case deadzone
        case scale
    }

    private enum InteractionKeys: String, CodingKey {
        case activationType
    }

    public var activation: TouchDirectionalPadActivation
    public var deadzone: Double
    public var scale: Double

    public init(
        activation: TouchDirectionalPadActivation = .allowNeighboring,
        deadzone: Double = 0.25,
        scale: Double = 1
    ) {
        self.activation = activation
        self.deadzone = deadzone
        self.scale = scale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let interaction = try? container.nestedContainer(
            keyedBy: InteractionKeys.self,
            forKey: .interaction
        )
        let defaults = TouchDirectionalPad()

        activation =
            try interaction?.decodeIfPresent(
                TouchDirectionalPadActivation.self,
                forKey: .activationType
            ) ?? defaults.activation
        deadzone =
            try container.decodeIfPresent(Double.self, forKey: .deadzone) ?? defaults.deadzone
        scale = try container.decodeIfPresent(Double.self, forKey: .scale) ?? defaults.scale
    }
}

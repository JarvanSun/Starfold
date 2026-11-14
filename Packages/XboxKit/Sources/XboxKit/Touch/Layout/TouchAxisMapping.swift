//
//  TouchAxisMapping.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchAxisMapping: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case input
        case output
        case sensitivity
        case deadzone
        case responseCurve
    }

    private enum ResponseCurveKeys: String, CodingKey {
        case type
    }

    public var input: TouchAxisInput
    public var output: TouchOutput
    public var sensitivity: Double
    public var deadzone: TouchDeadzone?
    public var responseCurve: TouchResponseCurve?

    public init(
        input: TouchAxisInput,
        output: TouchOutput,
        sensitivity: Double = 1,
        deadzone: TouchDeadzone? = nil,
        responseCurve: TouchResponseCurve? = nil
    ) {
        self.input = input
        self.output = output
        self.sensitivity = sensitivity
        self.deadzone = deadzone
        self.responseCurve = responseCurve
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let responseCurve = try? container.nestedContainer(
            keyedBy: ResponseCurveKeys.self,
            forKey: .responseCurve
        )
        let input = try container.decode(TouchAxisInput.self, forKey: .input)
        let output = try container.decode(TouchOutput.self, forKey: .output)
        let defaults = TouchAxisMapping(input: input, output: output)

        self.input = input
        self.output = output
        sensitivity =
            try container.decodeIfPresent(Double.self, forKey: .sensitivity) ?? defaults.sensitivity
        deadzone = try container.decodeIfPresent(TouchDeadzone.self, forKey: .deadzone)
        self.responseCurve = try responseCurve?.decode(TouchResponseCurve.self, forKey: .type)
    }
}

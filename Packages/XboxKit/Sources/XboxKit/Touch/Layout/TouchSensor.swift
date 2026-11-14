//
//  TouchSensor.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchSensor: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case axis
        case isEnabled = "enabled"
    }

    private enum SensorType: String {
        case gyroscope
        case accelerometer
        case blank
    }

    public var kind: TouchSensorKind
    public var axes: [TouchAxisMapping]
    public var isEnabled: Bool

    public init(kind: TouchSensorKind, axes: [TouchAxisMapping] = [], isEnabled: Bool = true) {
        self.kind = kind
        self.axes = axes
        self.isEnabled = isEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? ""
        let axes = try? container.decode(OneOrMany<TouchAxisMapping>.self, forKey: .axis)
        let defaults = TouchSensor(kind: .blank)

        switch (SensorType(rawValue: type), axes?.elements) {
        case (.gyroscope, let axes?): self.init(kind: .gyroscope, axes: axes)
        case (.accelerometer, let axes?): self.init(kind: .accelerometer, axes: axes)
        case (.blank, _): self.init(kind: .blank)
        default: self.init(kind: .unsupported(type: type))
        }

        isEnabled =
            (try? container.decodeIfPresent(Bool.self, forKey: .isEnabled)) ?? defaults.isEnabled
    }
}

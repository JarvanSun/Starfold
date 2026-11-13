//
//  TouchDeadzone.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchDeadzone: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case threshold
        case isRadial = "radial"
    }

    public var threshold: Double
    public var isRadial: Bool

    public init(threshold: Double, isRadial: Bool) {
        self.threshold = threshold
        self.isRadial = isRadial
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        threshold = try container.decodeIfPresent(Double.self, forKey: .threshold) ?? 0
        isRadial = try container.decodeIfPresent(Bool.self, forKey: .isRadial) ?? false
    }
}

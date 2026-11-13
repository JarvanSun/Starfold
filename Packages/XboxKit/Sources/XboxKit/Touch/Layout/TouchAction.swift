//
//  TouchAction.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchAction: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case target
        case action
        case interval
    }

    private enum ActionType: String {
        case layer
        case turbo
    }

    case output(TouchOutput)
    case layer(String)
    case turbo(TouchOutput, interval: Duration)
    case unsupported(String)

    public init(from decoder: Decoder) throws {
        switch try? decoder.singleValueContainer().decode(String.self) {
        case let name?: self = .output(.init(name: name))
        case nil: self = try .init(object: decoder.container(keyedBy: CodingKeys.self))
        }
    }

    private init(object: KeyedDecodingContainer<CodingKeys>) throws {
        let type = try object.decode(String.self, forKey: .type)

        switch ActionType(rawValue: type) {
        case .layer: self = .layer(try object.decode(String.self, forKey: .target))
        case .turbo:
            let milliseconds = try object.decode(Double.self, forKey: .interval)
            self = .turbo(
                try object.decode(TouchOutput.self, forKey: .action),
                interval: .milliseconds(milliseconds)
            )
        case nil: self = .unsupported(type)
        }
    }
}

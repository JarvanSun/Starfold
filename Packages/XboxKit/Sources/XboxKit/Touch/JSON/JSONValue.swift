//
//  JSONValue.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum JSONValue: Sendable, Hashable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    subscript(key: String) -> JSONValue? {
        switch self {
        case .object(let members): members[key]
        default: nil
        }
    }
}

// MARK: - Codable

extension JSONValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let scalar = (
            isNull: container.decodeNil(),
            flag: try? container.decode(Bool.self),
            number: try? container.decode(Double.self),
            text: try? container.decode(String.self)
        )

        switch scalar {
        case (true, _, _, _): self = .null
        case (_, let flag?, _, _): self = .bool(flag)
        case (_, _, let number?, _): self = .number(number)
        case (_, _, _, let text?): self = .string(text)
        default: self = try .init(containerIn: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .null: try container.encodeNil()
        case .bool(let flag): try container.encode(flag)
        case .number(let number): try container.encode(number)
        case .string(let text): try container.encode(text)
        case .array(let elements): try container.encode(elements)
        case .object(let members): try container.encode(members)
        }
    }

    private init(containerIn container: SingleValueDecodingContainer) throws {
        switch try? container.decode([JSONValue].self) {
        case let elements?: self = .array(elements)
        case nil: self = .object(try container.decode([String: JSONValue].self))
        }
    }
}

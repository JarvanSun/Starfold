//
//  JSONPatchOperation.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum JSONPatchOperation: Sendable, Hashable {
    case add(path: JSONPointer, value: JSONValue)
    case remove(path: JSONPointer)
    case replace(path: JSONPointer, value: JSONValue)
    case move(from: JSONPointer, path: JSONPointer)
    case copy(from: JSONPointer, path: JSONPointer)
    case test(path: JSONPointer, value: JSONValue)
}

// MARK: - Decodable

extension JSONPatchOperation: Decodable {
    private enum CodingKeys: String, CodingKey {
        case operation = "op"
        case path
        case value
        case from
    }

    private enum Name: String, Decodable {
        case add
        case remove
        case replace
        case move
        case copy
        case test
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let path = try container.decode(JSONPointer.self, forKey: .path)

        switch try container.decode(Name.self, forKey: .operation) {
        case .add:
            self = .add(path: path, value: try container.decode(JSONValue.self, forKey: .value))
        case .remove: self = .remove(path: path)
        case .replace:
            self = .replace(path: path, value: try container.decode(JSONValue.self, forKey: .value))
        case .move:
            self = .move(from: try container.decode(JSONPointer.self, forKey: .from), path: path)
        case .copy:
            self = .copy(from: try container.decode(JSONPointer.self, forKey: .from), path: path)
        case .test:
            self = .test(path: path, value: try container.decode(JSONValue.self, forKey: .value))
        }
    }
}

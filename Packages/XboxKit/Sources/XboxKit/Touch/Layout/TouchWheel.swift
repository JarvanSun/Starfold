//
//  TouchWheel.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchWheel: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case inner
        case outer
    }

    public var inner: [TouchSlot]
    public var outer: [TouchSlot]

    public init(inner: [TouchSlot] = [], outer: [TouchSlot] = []) {
        self.inner = inner
        self.outer = outer
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        inner = try container.decodeIfPresent([TouchSlot].self, forKey: .inner) ?? []
        outer = try container.decodeIfPresent([TouchSlot].self, forKey: .outer) ?? []
    }
}

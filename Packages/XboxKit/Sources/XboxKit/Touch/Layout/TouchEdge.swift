//
//  TouchEdge.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchEdge: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case left
        case leftCenter
        case center
        case rightCenter
        case right
    }

    public var left: [TouchSlot]
    public var leftCenter: [TouchSlot]
    public var center: [TouchSlot]
    public var rightCenter: [TouchSlot]
    public var right: [TouchSlot]

    public init(
        left: [TouchSlot] = [],
        leftCenter: [TouchSlot] = [],
        center: [TouchSlot] = [],
        rightCenter: [TouchSlot] = [],
        right: [TouchSlot] = []
    ) {
        self.left = left
        self.leftCenter = leftCenter
        self.center = center
        self.rightCenter = rightCenter
        self.right = right
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let slots = { (key: CodingKeys) throws -> [TouchSlot] in
            try container.decodeIfPresent(OneOrMany<TouchSlot>.self, forKey: key)?.elements ?? []
        }

        left = try slots(.left)
        leftCenter = try slots(.leftCenter)
        center = try slots(.center)
        rightCenter = try slots(.rightCenter)
        right = try slots(.right)
    }
}

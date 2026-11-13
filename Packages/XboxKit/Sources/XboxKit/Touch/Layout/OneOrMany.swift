//
//  OneOrMany.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

struct OneOrMany<Element: Decodable>: Decodable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        switch try? container.decode([Element].self) {
        case let elements?: self.elements = elements
        case nil: self.elements = [try container.decode(Element.self)]
        }
    }
}

//
//  TouchJSONDecoder.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

struct TouchJSONDecoder {
    private let byteOrderMark = Data([0xEF, 0xBB, 0xBF])

    func decode<Value: Decodable>(_ type: Value.Type, from json: Data) throws -> Value {
        let text = json.starts(with: byteOrderMark) ? json.dropFirst(byteOrderMark.count) : json
        return try JSONDecoder().decode(type, from: Data(text))
    }
}

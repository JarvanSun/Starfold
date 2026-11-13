//
//  JSONFixtureDecoder.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

struct JSONFixtureDecoder {
    func decode<Value: Decodable>(_ type: Value.Type, from json: String) throws -> Value {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }
}

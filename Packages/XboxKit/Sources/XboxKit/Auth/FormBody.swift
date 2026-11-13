//
//  FormBody.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct FormBody {
    private let fields: [(String, String)]

    var headers: [String: String] {
        ["Content-Type": "application/x-www-form-urlencoded"]
    }

    var encoded: Data {
        let text = fields.map { name, fieldValue in
            "\(percentEncoded(name))=\(percentEncoded(fieldValue))"
        }
        .joined(separator: "&")
        return Data(text.utf8)
    }

    private func percentEncoded(_ text: String) -> String {
        text.addingPercentEncoding(withAllowedCharacters: unreservedCharacters) ?? text
    }

    private var unreservedCharacters: CharacterSet {
        var characters = CharacterSet.alphanumerics
        characters.insert(charactersIn: "-._~")
        return characters
    }

    init(_ fields: [(String, String)]) {
        self.fields = fields
    }
}

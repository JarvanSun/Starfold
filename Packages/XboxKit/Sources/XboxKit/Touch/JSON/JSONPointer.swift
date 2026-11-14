//
//  JSONPointer.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct JSONPointer: Sendable, Hashable, CustomStringConvertible, Decodable {
    let tokens: [String]

    public var description: String {
        tokens.map { "/" + TokenEscaping().escaped($0) }.joined()
    }

    var parent: JSONPointer {
        .init(tokens: Array(tokens.dropLast()))
    }

    public init(_ text: String) throws(JSONPatchError) {
        guard text.isEmpty || text.hasPrefix("/") else { throw .invalidPointer(text) }

        let escapedTokens = text.split(separator: "/", omittingEmptySubsequences: false).dropFirst()
        var tokens: [String] = []

        for escapedToken in escapedTokens {
            guard let token = TokenEscaping().unescaped(escapedToken) else {
                throw .invalidPointer(text)
            }

            tokens.append(token)
        }

        self.tokens = tokens
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)

        do {
            try self.init(text)
        } catch {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid JSON Pointer \(text)"
            )
        }
    }

    init(tokens: [String]) {
        self.tokens = tokens
    }

    func isProperPrefix(of other: JSONPointer) -> Bool {
        tokens.count < other.tokens.count && other.tokens.starts(with: tokens)
    }

    func value(in document: JSONValue) -> JSONValue? {
        var current = document

        for token in tokens {
            guard let child = child(named: token, of: current) else { return nil }

            current = child
        }

        return current
    }

    private func child(named token: String, of container: JSONValue) -> JSONValue? {
        switch (container, arrayIndex(from: token)) {
        case (.object(let members), _): members[token]
        case (.array(let elements), let index?) where elements.indices.contains(index):
            elements[index]
        default: nil
        }
    }

    func arrayIndex(from token: String) -> Int? {
        let isDecimal = !token.isEmpty && token.allSatisfy { $0.isASCII && $0.isNumber }
        let hasLeadingZero = token.count > 1 && token.hasPrefix("0")
        guard isDecimal, !hasLeadingZero else { return nil }

        return Int(token)
    }
}

private struct TokenEscaping {
    func escaped(_ token: String) -> String {
        token.replacing("~", with: "~0").replacing("/", with: "~1")
    }

    func unescaped(_ escapedToken: Substring) -> String? {
        var token = ""
        var isEscaping = false

        for character in escapedToken {
            switch (isEscaping, character) {
            case (false, "~"): isEscaping = true
            case (false, _): token.append(character)
            case (true, "0"):
                token.append("~")
                isEscaping = false
            case (true, "1"):
                token.append("/")
                isEscaping = false
            case (true, _): return nil
            }
        }

        return isEscaping ? nil : token
    }
}

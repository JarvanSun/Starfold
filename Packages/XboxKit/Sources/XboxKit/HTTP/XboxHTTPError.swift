//
//  XboxHTTPError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct XboxHTTPError: LocalizedError, Sendable, CustomStringConvertible {
    public let url: URL
    public let statusCode: Int
    public let body: String

    let headers: [String: String]

    public var description: String {
        "HTTP \(statusCode) from \(url.host() ?? url.absoluteString): \(body.prefix(500))"
    }

    public var errorDescription: String? {
        let readableCode = body.trimmingCharacters(in: .whitespacesAndNewlines).prefix(200)
        let detail = readableCode.isEmpty ? "" : ": \(readableCode)"
        return "\(url.host() ?? "Server") returned \(statusCode)" + detail
    }

    public init(url: URL, statusCode: Int, body: String, headers: [String: String]) {
        self.url = url
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
}

//
//  HTTPURLResponseExtensions.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension HTTPURLResponse {
    var lowercasedHeaderFields: [String: String] {
        var headers: [String: String] = [:]

        for case (let name as String, let value as String) in allHeaderFields {
            headers[name.lowercased()] = value
        }

        return headers
    }
}

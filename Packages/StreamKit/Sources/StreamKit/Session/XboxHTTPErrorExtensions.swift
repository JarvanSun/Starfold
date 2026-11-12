//
//  XboxHTTPErrorExtensions.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension XboxHTTPError {
    var hostCode: String? {
        let json = try? JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any]
        return json?["code"] as? String
    }

    var isSessionGone: Bool {
        body.contains("SessionNotFound") || body.contains("SessionNotActive")
    }
}

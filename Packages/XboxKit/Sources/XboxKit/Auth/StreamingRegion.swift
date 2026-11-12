//
//  StreamingRegion.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct StreamingRegion: Codable, Sendable, Equatable, Hashable {
    var name: String
    var baseURL: URL
    var isDefault: Bool
    var fallbackPriority: Int
}

//
//  LibrarySnapshot.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

struct LibrarySnapshot: Codable {
    var games: [CloudGame]
    var recentIDs: [String]
    var curated: [String: [String]]
    var cloudAccess: String
}

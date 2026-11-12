//
//  HomeSnapshot.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

struct HomeSnapshot: Codable {
    var consoles: [Console]
    var lastPlayedHere: [String: ConsoleActivity]
}

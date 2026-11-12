//
//  PreviewObjectPoolSettings.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import XboxKit

extension PreviewObjectPool {
    static var accountChoices: [AccountChoice] {
        [
            .init(id: profile.xuid, gamertag: profile.gamertag, isActive: true),
            .init(id: "2535000000000001", gamertag: "LunarDrift", isActive: false),
        ]
    }
}

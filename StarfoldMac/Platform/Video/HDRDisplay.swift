//
//  HDRDisplay.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/10/01.
//

import AppKit

struct HDRDisplay {
    var isAvailable: Bool {
        NSScreen.screens.contains { $0.maximumPotentialExtendedDynamicRangeColorComponentValue > 1 }
    }
}

//
//  TouchTitleState.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/14.
//

import StreamKit
import XboxKit

struct TouchTitleState {
    var bundle: TouchBundle?
    var context = TouchContext()
    var pendingPatches: [JSONPatch] = []
    var reference: TouchLayoutReference = .standard
    var isHiddenByGame = false
}

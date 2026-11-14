//
//  TouchEdgeExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/14.
//

import XboxKit

extension TouchEdge {
    var slots: [TouchSlot] {
        [left, leftCenter, center, rightCenter, right].flatMap { $0 }
    }
}

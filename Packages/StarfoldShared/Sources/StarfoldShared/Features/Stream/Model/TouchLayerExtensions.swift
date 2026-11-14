//
//  TouchLayerExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import XboxKit

extension TouchLayer {
    var isDrawable: Bool {
        let wheelSlots: [TouchSlot] = [left, right].flatMap { $0.inner + $0.outer }
        let edgeSlots: [TouchSlot] = [upper, lower].flatMap(\.slots)
        let centerSlots: [TouchSlot] = center.inner + center.outer
        return (wheelSlots + edgeSlots).allSatisfy(\.isDrawable)
            && centerSlots.allSatisfy(\.isHidden)
    }
}

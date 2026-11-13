//
//  TouchLayerExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import XboxKit

extension TouchLayer {
    var isDrawable: Bool {
        let wheelSlots: [TouchSlot] = [left, right, center].flatMap { $0.inner + $0.outer }
        let edgeSlots: [TouchSlot] = [upper, lower].flatMap(slots(on:))
        return (wheelSlots + edgeSlots).allSatisfy(isDrawable)
    }

    private func slots(on edge: TouchEdge) -> [TouchSlot] {
        [edge.left, edge.leftCenter, edge.center, edge.rightCenter, edge.right].flatMap { $0 }
    }

    private func isDrawable(_ slot: TouchSlot) -> Bool {
        switch slot {
        case .empty: true
        case .control(let control): isDrawable(control)
        case .cluster(let controls): controls.compactMap { $0 }.allSatisfy(isDrawable)
        }
    }

    private func isDrawable(_ control: TouchControl) -> Bool {
        switch control.kind {
        case .blank: true
        default: !control.isVisible || TouchInput(kind: control.kind) != nil
        }
    }
}

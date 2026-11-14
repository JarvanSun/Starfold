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
        let edgeSlots: [TouchSlot] = [upper, lower].flatMap(slots(on:))
        let centerSlots: [TouchSlot] = center.inner + center.outer
        return (wheelSlots + edgeSlots).allSatisfy(isDrawable) && centerSlots.allSatisfy(isHidden)
    }

    private func slots(on edge: TouchEdge) -> [TouchSlot] {
        [edge.left, edge.leftCenter, edge.center, edge.rightCenter, edge.right].flatMap { $0 }
    }

    private func isDrawable(_ slot: TouchSlot) -> Bool {
        switch slot {
        case .empty: true
        case .control(let control): isDrawable(control)
        case .cluster(let controls): isDrawable(cluster: controls.compactMap { $0 })
        }
    }

    private func isDrawable(cluster controls: [TouchControl]) -> Bool {
        let shown = controls.filter(isShown)
        return shown.count <= 1 && shown.allSatisfy(isDrawable)
    }

    private func isHidden(_ slot: TouchSlot) -> Bool {
        switch slot {
        case .empty: true
        case .control(let control): !isShown(control)
        case .cluster(let controls): !controls.compactMap { $0 }.contains(where: isShown)
        }
    }

    private func isShown(_ control: TouchControl) -> Bool {
        switch control.kind {
        case .blank: false
        default: control.isVisible
        }
    }

    private func isDrawable(_ control: TouchControl) -> Bool {
        guard isShown(control) else { return true }

        switch control.kind {
        case .button(let button) where button.isToggle || button.pullAction != nil: return false
        default: return TouchInput(kind: control.kind) != nil
        }
    }
}

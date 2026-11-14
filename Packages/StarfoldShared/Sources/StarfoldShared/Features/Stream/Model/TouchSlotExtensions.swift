//
//  TouchSlotExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/14.
//

import XboxKit

extension TouchSlot {
    var isDrawable: Bool {
        switch self {
        case .empty: true
        case .control(let control): control.isDrawable
        case .cluster(let controls): isDrawable(cluster: controls.compactMap { $0 })
        }
    }

    private func isDrawable(cluster controls: [TouchControl]) -> Bool {
        let shown = controls.filter(\.isShown)
        return shown.count <= 1 && shown.allSatisfy(\.isDrawable)
    }

    var isHidden: Bool {
        switch self {
        case .empty: true
        case .control(let control): !control.isShown
        case .cluster(let controls): !controls.compactMap { $0 }.contains(where: \.isShown)
        }
    }
}

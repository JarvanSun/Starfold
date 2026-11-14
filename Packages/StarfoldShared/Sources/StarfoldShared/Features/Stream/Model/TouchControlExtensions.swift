//
//  TouchControlExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/14.
//

import XboxKit

extension TouchControl {
    var isShown: Bool {
        switch kind {
        case .blank: false
        default: isVisible
        }
    }

    var isDrawable: Bool {
        guard isShown else { return true }

        switch kind {
        case .button(let button) where button.isToggle || button.pullAction != nil: return false
        default: return TouchInput(kind: kind) != nil
        }
    }
}

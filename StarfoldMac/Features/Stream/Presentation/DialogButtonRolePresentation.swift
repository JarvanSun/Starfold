//
//  DialogButtonRolePresentation.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

extension DialogButtonRole {
    var keyboardShortcut: KeyboardShortcut? {
        switch self {
        case .primary: .defaultAction
        case .cancel: .cancelAction
        case .plain: nil
        }
    }
}

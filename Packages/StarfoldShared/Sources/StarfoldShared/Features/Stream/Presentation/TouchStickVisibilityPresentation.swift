//
//  TouchStickVisibilityPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension TouchStickVisibility {
    public var title: LocalizedStringResource {
        switch self {
        case .always: .init("touch.stick.always", bundle: .module)
        case .onTouch: .init("touch.stick.onTouch", bundle: .module)
        case .off: .init("touch.stick.off", bundle: .module)
        }
    }

    public var placeholderSymbol: String? {
        switch self {
        case .always: nil
        case .onTouch: "hand.tap"
        case .off: "eye.slash"
        }
    }
}

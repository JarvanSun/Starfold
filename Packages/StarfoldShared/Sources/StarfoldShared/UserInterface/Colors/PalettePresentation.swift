//
//  PalettePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension Palette {
    var name: LocalizedStringResource {
        switch id {
        case .nebula: .init("palette.nebula.name", bundle: .module)
        case .aurora: .init("palette.aurora.name", bundle: .module)
        case .sunrise: .init("palette.sunrise.name", bundle: .module)
        }
    }
}

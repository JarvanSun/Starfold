//
//  EnvironmentValuesExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension EnvironmentValues {
    @Entry public var skipsEntranceAnimations = false
    @Entry public var palette = Palette(.nebula)
    @Entry public var dimensions = Dimensions()
    @Entry public var skyCanvasSize: CGSize?
}

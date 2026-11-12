//
//  SkyStyle.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

nonisolated struct SkyStyle: Equatable, Sendable {
    let top: RGBColor
    let bottom: RGBColor
    let glow: SkyGlow
    let ribbons: SkyRibbons
}

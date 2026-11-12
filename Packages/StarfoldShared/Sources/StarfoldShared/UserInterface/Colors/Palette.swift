//
//  Palette.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/30.
//

import SwiftUI

public nonisolated struct Palette: Identifiable, Equatable, Sendable {
    public let id: PaletteID
    let sky: SkyStyle
    let primary: [RGBColor]
    let primaryLabel: RGBColor
    let hasPrimaryGlow: Bool
    public let accent: RGBColor
    public let night: RGBColor
    public let nightRaised: RGBColor

    var primaryLabelColor: Color {
        switch id {
        case .sunrise: .black.opacity(0.85)
        case .nebula, .aurora: primaryLabel.color
        }
    }

    public var primaryTint: Color {
        (primary.last ?? accent).color
    }

    public var primaryFill: LinearGradient {
        .init(colors: primary.map(\.color), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    public init(_ id: PaletteID) {
        self.id = id

        switch id {
        case .nebula:
            sky = .init(
                top: .init(0x0A0A1C),
                bottom: .init(0x1B1442),
                glow: .init(tint: .init(0x6B5CFF), strength: 0.45),
                ribbons: .init(
                    first: .init(0x7B6CFF),
                    second: .init(0xA99FFF),
                    third: .init(0x5B45D6),
                    strength: 0.6
                )
            )
            primary = [.init(0x6652E8)]
            primaryLabel = .init(0xFFFFFF)
            hasPrimaryGlow = false
            accent = .init(0xA99FFF)
            night = .init(0x0B0A1E)
            nightRaised = .init(0x1B1640)
        case .aurora:
            sky = .init(
                top: .init(0x05141A),
                bottom: .init(0x0A2229),
                glow: .init(tint: .init(0x3DDBB0), strength: 0.4),
                ribbons: .init(
                    first: .init(0x3DDBB0),
                    second: .init(0x33B3D9),
                    third: .init(0x73F2CC),
                    strength: 0.6
                )
            )
            primary = [.init(0x0A8470)]
            primaryLabel = .init(0xFFFFFF)
            hasPrimaryGlow = false
            accent = .init(0x3DDBB0)
            night = .init(0x05141A)
            nightRaised = .init(0x0C2830)
        case .sunrise:
            let amber = RGBColor(red: 1.0, green: 0.690, blue: 0.259)
            let coral = RGBColor(red: 1.0, green: 0.408, blue: 0.294)
            sky = .init(
                top: .init(red: 0.030, green: 0.040, blue: 0.075),
                bottom: .init(red: 0.070, green: 0.055, blue: 0.090),
                glow: .init(tint: .init(red: 1.0, green: 0.45, blue: 0.22), strength: 0.55),
                ribbons: .init(
                    first: .init(red: 1.0, green: 0.69, blue: 0.26),
                    second: .init(red: 1.0, green: 0.41, blue: 0.29),
                    third: .init(red: 0.91, green: 0.29, blue: 0.48),
                    strength: 1
                )
            )
            primary = [amber, coral]
            primaryLabel = .init(red: 0.15, green: 0.1035, blue: 0.0389)
            hasPrimaryGlow = true
            accent = amber
            night = .init(red: 0.035, green: 0.047, blue: 0.086)
            nightRaised = .init(red: 0.075, green: 0.090, blue: 0.140)
        }
    }
}

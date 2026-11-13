//
//  RGBColor.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftUI

public struct RGBColor: Equatable, Sendable {
    let red: Double
    let green: Double
    let blue: Double

    public var color: Color {
        .init(.sRGB, red: red, green: green, blue: blue)
    }

    var luminance: Double {
        0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }

    private func linear(_ component: Double) -> Double {
        switch component <= 0.04045 {
        case true: component / 12.92
        case false: pow((component + 0.055) / 1.055, 2.4)
        }
    }

    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    init(_ hex: UInt32) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
    }

    func contrast(with other: RGBColor) -> Double {
        let lighter = max(luminance, other.luminance)
        let darker = min(luminance, other.luminance)
        return (lighter + 0.05) / (darker + 0.05)
    }
}

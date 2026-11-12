//
//  Dimensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics

public struct Dimensions: Sendable {
    public var spaceXXSmall: CGFloat { 2 }

    public var spaceXSmall: CGFloat { 4 }

    public var spaceSmall: CGFloat { 8 }

    public var spaceMedium: CGFloat { 12 }

    public var spaceLarge: CGFloat { 16 }

    public var spaceXLarge: CGFloat { 24 }

    public var spaceXXLarge: CGFloat { 32 }

    public var spaceXXXLarge: CGFloat { 48 }

    public var spaceHuge: CGFloat { 64 }

    public var cornerRadiusSmall: CGFloat { 8 }

    public var cornerRadiusMedium: CGFloat { 12 }

    public var cornerRadiusLarge: CGFloat { 16 }

    public var cornerRadiusXLarge: CGFloat { 24 }

    public var cornerRadiusXXLarge: CGFloat { 32 }

    public var shadowRadiusSmall: CGFloat { 6 }

    public var shadowRadiusMedium: CGFloat { 14 }

    public var shadowRadiusLarge: CGFloat { 30 }

    public var shadowOffsetSmall: CGFloat { 3 }

    public var shadowOffsetMedium: CGFloat { 8 }

    public var shadowOffsetLarge: CGFloat { 18 }

    public var hairline: CGFloat { 1 }

    public var mainWindowWidth: CGFloat { 1180 }

    public var mainWindowHeight: CGFloat { 760 }

    public var streamWindowWidth: CGFloat { 1280 }

    public var streamWindowHeight: CGFloat { 720 }

    public var streamWindowMinimumWidth: CGFloat { 640 }

    public var streamWindowMinimumHeight: CGFloat { 360 }

    public var circleButtonSize: CGFloat { 34 }

    var highlightBorderWidth: CGFloat { 2 }

    var statusDotSize: CGFloat { 8 }

    var paletteSwatchSize: CGFloat { 12 }

    public init() {}
}

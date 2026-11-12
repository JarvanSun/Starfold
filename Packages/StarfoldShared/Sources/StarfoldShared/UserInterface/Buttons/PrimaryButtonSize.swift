//
//  PrimaryButtonSize.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public enum PrimaryButtonSize {
    case regular
    case compact
    case large

    var font: Font {
        switch self {
        case .regular: .body.weight(.semibold)
        case .compact: .callout.weight(.semibold)
        case .large: .title3.weight(.semibold)
        }
    }

    func horizontalPadding(in dimensions: Dimensions) -> CGFloat {
        switch self {
        case .regular: dimensions.spaceLarge
        case .compact: dimensions.spaceMedium
        case .large: dimensions.spaceXLarge
        }
    }

    func verticalPadding(in dimensions: Dimensions) -> CGFloat {
        switch self {
        case .regular: dimensions.spaceSmall
        case .compact: dimensions.spaceSmall
        case .large: dimensions.spaceMedium
        }
    }
}

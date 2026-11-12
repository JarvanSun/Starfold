//
//  ButtonStyleExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static var primary: PrimaryButtonStyle {
        .init(size: .regular)
    }

    public static var primaryLarge: PrimaryButtonStyle {
        .init(size: .large)
    }
}

extension ButtonStyle where Self == CircleIconButtonStyle {
    public static var circleIcon: CircleIconButtonStyle {
        .init()
    }
}

//
//  ShapeStyleExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    public static var online: Color {
        .init(red: 0.310, green: 0.851, blue: 0.494)
    }

    public static var standby: Color {
        .gray
    }

    public static var attention: Color {
        .init(red: 1.0, green: 0.780, blue: 0.260)
    }

    public static var cardFill: Color {
        .white.opacity(0.06)
    }

    public static var cardStroke: Color {
        .white.opacity(0.10)
    }
}

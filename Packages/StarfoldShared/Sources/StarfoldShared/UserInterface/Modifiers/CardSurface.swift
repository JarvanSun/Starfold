//
//  CardSurface.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension View {
    public func cardSurface(cornerRadius: CGFloat? = nil, highlighted: Bool = false) -> some View {
        modifier(CardSurface(cornerRadius: cornerRadius, isHighlighted: highlighted))
    }
}

private struct CardSurface: ViewModifier {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let cornerRadius: CGFloat?
    let isHighlighted: Bool

    func body(content: Content) -> some View {
        let materialOpacity = 0.9

        return
            content
            .background(
                .ultraThinMaterial.opacity(materialOpacity),
                in: .rect(cornerRadius: radius)
            )
            .background(.cardFill, in: .rect(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(border, lineWidth: borderWidth)
            }
    }

    private var radius: CGFloat {
        cornerRadius ?? dimensions.cornerRadiusXLarge
    }

    private var border: AnyShapeStyle {
        isHighlighted ? .init(palette.primaryFill) : .init(.cardStroke)
    }

    private var borderWidth: CGFloat {
        isHighlighted ? dimensions.highlightBorderWidth : dimensions.hairline
    }
}

#if DEBUG
#Preview("Plain and highlighted") {
    HStack {
        Color.clear
            .frame(width: 200, height: 120)
            .cardSurface()

        Color.clear
            .frame(width: 200, height: 120)
            .cardSurface(highlighted: true)
    }
    .padding()
    .background(Palette(.nebula).night.color)
}
#endif

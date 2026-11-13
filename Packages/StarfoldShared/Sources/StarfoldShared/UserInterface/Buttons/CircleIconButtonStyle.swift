//
//  CircleIconButtonStyle.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct CircleIconButtonStyle: ButtonStyle {
    @Environment(\.dimensions) private var dimensions
    @State private var isHovering = false

    private let size: CGFloat?

    public init(size: CGFloat? = nil) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        let symbolScale: CGFloat = 0.42
        let symbolOpacity = 0.9
        let fillOpacity = 0.12
        let hoverFillOpacity = 0.2
        let pressedScale: CGFloat = 0.9

        return configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: diameter * symbolScale, weight: .semibold))
            .foregroundStyle(.white.opacity(symbolOpacity))
            .frame(width: diameter, height: diameter)
            .background(
                Color.white.opacity(isHovering ? hoverFillOpacity : fillOpacity),
                in: .circle
            )
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(pressAnimation, value: configuration.isPressed)
            .animation(hoverAnimation, value: isHovering)
            #if !os(tvOS)
        .onHover { isHovering = $0 }
            #endif
            .contentShape(.circle)
    }

    private var diameter: CGFloat {
        size ?? dimensions.circleButtonSize
    }

    private var pressAnimation: Animation {
        .spring(duration: 0.2, bounce: 0.4)
    }

    private var hoverAnimation: Animation {
        .easeOut(duration: 0.15)
    }
}

#if DEBUG
#Preview {
    Button(action: {}) {
        Label {
            Text(verbatim: "Close")
        } icon: {
            Image(systemName: "xmark")
        }
    }
    .buttonStyle(.circleIcon)
    .padding()
    .background(.black)
}
#endif

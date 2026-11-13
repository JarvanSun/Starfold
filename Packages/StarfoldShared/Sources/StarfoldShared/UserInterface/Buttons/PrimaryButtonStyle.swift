//
//  PrimaryButtonStyle.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    private let size: PrimaryButtonSize

    public init(size: PrimaryButtonSize) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        let pressedScale: CGFloat = 0.96
        let disabledOpacity = 0.4

        return configuration.label
            .font(size.font)
            .foregroundStyle(palette.primaryLabelColor)
            .padding(.horizontal, size.horizontalPadding(in: dimensions))
            .padding(.vertical, size.verticalPadding(in: dimensions))
            .background(palette.primaryFill, in: .capsule)
            .overlay(hoverLight(isPressed: configuration.isPressed))
            .overlay(rim)
            .shadow(
                color: glow(isPressed: configuration.isPressed),
                radius: glowRadius(isPressed: configuration.isPressed),
                y: dimensions.spaceXSmall
            )
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .opacity(isEnabled ? 1 : disabledOpacity)
            .saturation(isEnabled ? 1 : 0)
            .scaleEffect(hoverScale(isPressed: configuration.isPressed))
            .animation(pressAnimation, value: configuration.isPressed)
            .animation(hoverAnimation, value: isHovering)
            #if !os(tvOS)
        .onHover { isHovering = $0 }
            #endif
            .contentShape(.capsule)
    }

    private func hoverLight(isPressed: Bool) -> some View {
        let hoverLightOpacity = 0.14

        return Capsule().fill(
            .white.opacity(isHoverLit(isPressed: isPressed) ? hoverLightOpacity : 0)
        )
    }

    private var rim: some View {
        let rimOpacity = 0.35

        return Capsule()
            .strokeBorder(.white.opacity(rimOpacity), lineWidth: dimensions.hairline)
            .blendMode(.overlay)
    }

    private func glow(isPressed: Bool) -> Color {
        let glowOpacity = 0.45
        let pressedGlowOpacity = 0.2

        return glowColor.opacity(isPressed ? pressedGlowOpacity : glowOpacity)
    }

    private var glowColor: Color {
        let shadowOpacity = 0.6

        return switch palette.hasPrimaryGlow {
        case true: palette.primaryTint
        case false: .black.opacity(shadowOpacity)
        }
    }

    private func glowRadius(isPressed: Bool) -> CGFloat {
        isPressed ? dimensions.shadowRadiusSmall : dimensions.shadowRadiusMedium
    }

    private func hoverScale(isPressed: Bool) -> CGFloat {
        let growsUnderPointer = isHoverLit(isPressed: isPressed) && !reduceMotion
        let hoverGrowth: CGFloat = 1.03

        return growsUnderPointer ? hoverGrowth : 1
    }

    private func isHoverLit(isPressed: Bool) -> Bool {
        isHovering && isEnabled && !isPressed
    }

    private var pressAnimation: Animation {
        .spring(duration: 0.25, bounce: 0.4)
    }

    private var hoverAnimation: Animation {
        .easeOut(duration: 0.15)
    }
}

#if DEBUG
#Preview("Sizes and palettes") {
    HStack {
        ForEach(PaletteID.allCases, id: \.self) { id in
            VStack {
                ForEach([PrimaryButtonSize.compact, .regular, .large], id: \.self) { size in
                    Button(action: {}) {
                        Text(verbatim: "\(id) \(size)")
                    }
                    .buttonStyle(PrimaryButtonStyle(size: size))
                }

                Button(action: {}) {
                    Text(verbatim: "\(id) disabled")
                }
                .buttonStyle(.primary)
                .disabled(true)
            }
            .padding()
            .background(Palette(id).night.color)
            .palette(Palette(id))
        }
    }
}
#endif

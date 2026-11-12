//
//  HoverLift.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

extension View {
    func hoverLift(isHovering: Bool) -> some View {
        modifier(HoverLift(isHovering: isHovering))
    }
}

private struct HoverLift: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions

    let isHovering: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isLifted ? liftedScale : 1)
            .shadow(
                color: .black.opacity(isHovering ? 0.5 : 0.25),
                radius: isHovering ? dimensions.shadowRadiusMedium : dimensions.shadowRadiusSmall,
                y: isHovering ? dimensions.shadowOffsetMedium : dimensions.shadowOffsetSmall
            )
    }
}

private extension HoverLift {
    var liftedScale: CGFloat {
        1.05
    }

    var isLifted: Bool {
        isHovering && !reduceMotion
    }
}

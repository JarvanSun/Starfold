//
//  EditableTouchControl.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct EditableTouchControl: View {
    @Environment(\.dimensions) private var dimensions

    let placement: TouchControlPlacement
    let isSelected: Bool

    let onMove: (CGSize) -> Void
    let onEndMove: () -> Void
    let onSelect: () -> Void

    var body: some View {
        Circle()
            .strokeBorder(.tint, lineWidth: dimensions.highlightLineWidth)
            .opacity(isSelected ? 1 : 0)
            .frame(width: placement.diameter, height: placement.diameter)
            .contentShape(.circle)
            .onTapGesture { onSelect() }
            .gesture(drag)
            .accessibilityElement()
            .accessibilityLabel(Text(placement.input.title))
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: dimensions.spaceXSmall)
            .onChanged { onMove($0.translation) }
            .onEnded { _ in onEndMove() }
    }
}

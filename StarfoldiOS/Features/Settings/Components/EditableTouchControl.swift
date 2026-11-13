//
//  EditableTouchControl.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct EditableTouchControl: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions
    @State private var drops = 0
    @GestureState private var isDragging = false

    let placement: TouchControlPlacement
    let isSelected: Bool

    let onMove: (CGSize) -> Void
    let onEndMove: () -> Void
    let onSelect: () -> Void

    var body: some View {
        Circle()
            .strokeBorder(palette.accent.color, lineWidth: dimensions.highlightLineWidth)
            .opacity(isSelected ? 1 : 0)
            .frame(width: placement.diameter, height: placement.diameter)
            .contentShape(.circle)
            .onTapGesture { onSelect() }
            .gesture(drag)
            .accessibilityElement()
            .accessibilityLabel(Text(placement.input.title))
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .sensoryFeedback(.impact(weight: .heavy), trigger: isSelected) { _, isSelected in
                isSelected
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: drops)
            .onChange(of: isDragging) { _, isDragging in
                if !isDragging { endMove() }
            }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: dimensions.spaceXSmall, coordinateSpace: .global)
            .updating($isDragging) { _, isDragging, _ in isDragging = true }
            .onChanged { onMove($0.translation) }
    }

    private func endMove() {
        drops += 1
        onEndMove()
    }
}

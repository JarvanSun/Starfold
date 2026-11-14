//
//  BesideLayout.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI

struct BesideLayout: Layout {
    let anchor: CGPoint
    let clearance: CGFloat
    let insets: EdgeInsets

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            subview.place(at: origin(of: size, in: bounds), proposal: .init(size))
        }
    }

    private func origin(of size: CGSize, in bounds: CGRect) -> CGPoint {
        let isInRightHalf = anchor.x > bounds.width / 2
        let x = isInRightHalf ? anchor.x - clearance - size.width : anchor.x + clearance
        let lowestY = bounds.height - insets.bottom - size.height
        let y = min(max(anchor.y - size.height / 2, insets.top), lowestY)

        return CGPoint(x: bounds.minX + x, y: bounds.minY + y)
    }
}

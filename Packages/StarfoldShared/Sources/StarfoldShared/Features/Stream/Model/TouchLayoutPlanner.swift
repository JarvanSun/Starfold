//
//  TouchLayoutPlanner.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import Foundation
import StreamKit
import XboxKit

struct TouchLayoutPlanner {
    private struct PlannedControl {
        let id: String
        let input: TouchInput
    }

    let metrics: TouchMetrics
    let adjustments: TouchLayoutAdjustments

    private let wheelArcDegrees: Double = 100
    private let clusterSpacing: CGFloat = 1.05

    func plan(for layer: TouchLayer) -> TouchControlPlan {
        let placements =
            leftWheel(layer.left) + rightWheel(layer.right)
            + edge(layer.upper, isTop: true) + edge(layer.lower, isTop: false)
        return .init(controls: placements.map(adjusted), opacity: adjustments.opacity)
    }

    private var clusterRadius: CGFloat {
        metrics.buttonDiameter * clusterSpacing
    }

    private func adjusted(_ placement: TouchControlPlacement) -> TouchControlPlacement {
        let adjustment = adjustments.adjustment(for: placement.id)
        return .init(
            id: placement.id,
            input: placement.input,
            anchor: placement.anchor,
            offset: CGPoint(
                x: placement.offset.x + adjustment.offset.x,
                y: placement.offset.y + adjustment.offset.y
            ),
            diameter: placement.diameter * adjustment.scale,
            symbol: placement.symbol
        )
    }

    private func leftWheel(_ wheel: TouchWheel) -> [TouchControlPlacement] {
        let reach = metrics.edgeMargin + metrics.stickDiameter / 2
        let center = CGPoint(x: reach, y: -reach)
        let inner = innerControls(wheel.inner, id: "left.inner", anchor: .bottomLeading, at: center)
        let outer = ring(
            controls(in: wheel.outer, id: "left.outer"),
            anchor: .bottomLeading,
            around: center,
            innerRadius: radius(of: inner),
            from: 0,
            to: wheelArcDegrees,
            direction: 1
        )
        return inner + outer
    }

    private func rightWheel(_ wheel: TouchWheel) -> [TouchControlPlacement] {
        let reach = metrics.edgeMargin + clusterRadius + metrics.buttonDiameter / 2
        let center = CGPoint(x: -reach, y: -reach)
        let inner = innerControls(
            wheel.inner,
            id: "right.inner",
            anchor: .bottomTrailing,
            at: center
        )
        let outer = ring(
            controls(in: wheel.outer, id: "right.outer"),
            anchor: .bottomTrailing,
            around: center,
            innerRadius: radius(of: inner),
            from: wheelArcDegrees,
            to: 0,
            direction: -1
        )
        return inner + outer
    }

    private func innerControls(
        _ slots: [TouchSlot],
        id: String,
        anchor: TouchAnchor,
        at center: CGPoint
    ) -> [TouchControlPlacement] {
        let controls = controls(in: slots, id: id)

        switch controls.count {
        case 0: return []
        case 1: return [place(controls[0], anchor: anchor, at: center)]
        default: return cluster(controls, anchor: anchor, around: center)
        }
    }

    private func cluster(
        _ controls: [PlannedControl],
        anchor: TouchAnchor,
        around center: CGPoint
    ) -> [TouchControlPlacement] {
        let topDegrees: Double = 90
        let step = 360 / Double(controls.count)

        return controls.enumerated().map { index, control in
            let position = point(
                around: center,
                radius: clusterRadius,
                degrees: topDegrees - Double(index) * step
            )
            return place(control, anchor: anchor, at: position)
        }
    }

    private func radius(of inner: [TouchControlPlacement]) -> CGFloat {
        switch inner.count {
        case 0: 0
        case 1: inner[0].diameter / 2
        default: clusterRadius + metrics.buttonDiameter / 2
        }
    }

    private func ring(
        _ controls: [PlannedControl],
        anchor: TouchAnchor,
        around center: CGPoint,
        innerRadius: CGFloat,
        from startDegrees: Double,
        to endDegrees: Double,
        direction: CGFloat
    ) -> [TouchControlPlacement] {
        let gap = metrics.edgeMargin / 2
        let lastIndex = max(controls.count - 1, 1)

        return controls.enumerated().map { index, control in
            let progress = Double(index) / Double(lastIndex)
            let degrees = startDegrees + (endDegrees - startDegrees) * progress
            let radius = innerRadius + gap + diameter(of: control.input) / 2
            let position = point(
                around: center,
                radius: radius,
                degrees: degrees,
                direction: direction
            )
            return place(control, anchor: anchor, at: position)
        }
    }

    private func point(
        around center: CGPoint,
        radius: CGFloat,
        degrees: Double,
        direction: CGFloat = 1
    ) -> CGPoint {
        let radians = degrees * .pi / 180
        return CGPoint(
            x: center.x + direction * radius * CGFloat(cos(radians)),
            y: center.y - radius * CGFloat(sin(radians))
        )
    }

    private func edge(_ edge: TouchEdge, isTop: Bool) -> [TouchControlPlacement] {
        let name = isTop ? "upper" : "lower"
        let side = isTop ? 1 : -1 as CGFloat
        let vertical = side * (metrics.edgeMargin + metrics.smallButtonDiameter / 2)
        let corner = isTop ? TouchAnchor.top : .bottom
        return row(
            controls(in: edge.left, id: "\(name).left"),
            anchor: isTop ? .topLeading : .bottomLeading,
            vertical: vertical,
            direction: 1
        )
            + row(
                controls(in: edge.leftCenter, id: "\(name).leftCenter"),
                anchor: corner,
                vertical: vertical,
                direction: -1
            )
            + row(
                controls(in: edge.center, id: "\(name).center"),
                anchor: corner,
                vertical: vertical,
                direction: 1
            )
            + row(
                controls(in: edge.rightCenter, id: "\(name).rightCenter"),
                anchor: corner,
                vertical: vertical,
                direction: 1
            )
            + row(
                controls(in: edge.right, id: "\(name).right"),
                anchor: isTop ? .topTrailing : .bottomTrailing,
                vertical: vertical,
                direction: -1
            )
    }

    private func row(
        _ controls: [PlannedControl],
        anchor: TouchAnchor,
        vertical: CGFloat,
        direction: CGFloat
    ) -> [TouchControlPlacement] {
        let step = metrics.smallButtonDiameter + metrics.edgeMargin / 2
        let start = metrics.edgeMargin + metrics.smallButtonDiameter / 2

        return controls.enumerated().map { index, control in
            let position = CGPoint(x: direction * (start + CGFloat(index) * step), y: vertical)
            return place(
                control,
                anchor: anchor,
                at: position,
                diameter: metrics.smallButtonDiameter
            )
        }
    }

    private func controls(in slots: [TouchSlot], id: String) -> [PlannedControl] {
        slots.enumerated().compactMap { index, slot in
            switch slot {
            case .empty: nil
            case .control(let control): planned(control, id: "\(id).\(index)")
            case .cluster(let controls):
                controls.lazy.compactMap { $0 }.compactMap { planned($0, id: "\(id).\(index)") }
                    .first
            }
        }
    }

    private func planned(_ control: TouchControl, id: String) -> PlannedControl? {
        guard control.isVisible, let input = TouchInput(kind: control.kind) else { return nil }

        return .init(id: id, input: input)
    }

    private func place(
        _ control: PlannedControl,
        anchor: TouchAnchor,
        at position: CGPoint,
        diameter: CGFloat? = nil
    ) -> TouchControlPlacement {
        .init(
            id: control.id,
            input: control.input,
            anchor: anchor,
            offset: position,
            diameter: diameter ?? self.diameter(of: control.input),
            symbol: control.input.symbol
        )
    }

    private func diameter(of input: TouchInput) -> CGFloat {
        let directionPadScale: CGFloat = 0.8

        return switch input {
        case .leftStick, .rightStick: metrics.stickDiameter
        case .directionPad: metrics.stickDiameter * directionPadScale
        case .button, .leftTrigger, .rightTrigger: metrics.buttonDiameter
        }
    }
}

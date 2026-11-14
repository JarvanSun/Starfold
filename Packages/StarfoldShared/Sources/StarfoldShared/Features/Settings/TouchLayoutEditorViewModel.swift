//
//  TouchLayoutEditorViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import Observation
import XboxKit

@Observable
public final class TouchLayoutEditorViewModel {
    public private(set) var orientation: TouchOrientation = .landscape

    public let scaleRange: ClosedRange<Double> = 0.7...1.5
    public let opacityRange: ClosedRange<Double> = 0.3...1

    private let preferences: Preferences
    private let standard = StandardTouchLayout()

    private var adjustments = TouchLayoutAdjustments()
    private var selected: TouchControlPlacement?
    private var movingFrom: (id: String, offset: CGPoint)?

    public var selectedID: String? {
        selected?.id
    }

    public var opacity: Double {
        get { adjustments.opacity }
        set { change { $0.opacity = newValue } }
    }

    private func change(_ update: (inout TouchLayoutAdjustments) -> Void) {
        update(&adjustments)

        save()
    }

    private func save() {
        preferences.setTouchLayoutAdjustments(adjustments, for: orientation)
    }

    public var selectedStickVisibility: TouchStickVisibility {
        get { selected.map { preferences.touchSticks.visibility(of: $0.input) } ?? .always }
        set {
            guard let selected else { return }

            preferences.touchSticks.setVisibility(newValue, of: selected.input)
        }
    }

    public var isStickSelected: Bool {
        switch selected?.input {
        case .leftStick, .rightStick: true
        case .button, .leftTrigger, .rightTrigger, .directionPad, nil: false
        }
    }

    public var canResizeSelection: Bool {
        hasSelection && selectedStickVisibility != .off
    }

    public var selectedScale: Double {
        get { selectedID.map { adjustments.adjustment(for: $0).scale } ?? 1 }
        set { changeSelected { $0.scale = newValue } }
    }

    private func changeSelected(_ update: (inout TouchControlAdjustment) -> Void) {
        guard let selectedID else { return }

        change { update(&$0.controls[selectedID, default: .init()]) }
    }

    var hasSelection: Bool {
        selectedID != nil
    }

    public var isMoving: Bool {
        movingFrom != nil
    }

    init(preferences: Preferences) {
        self.preferences = preferences
        adjustments = preferences.touchLayoutAdjustments(for: orientation)
    }

    public func show(_ orientation: TouchOrientation) {
        guard orientation != self.orientation else { return }

        self.orientation = orientation
        adjustments = preferences.touchLayoutAdjustments(for: orientation)
        select(nil)
    }

    public func select(_ placement: TouchControlPlacement?) {
        selected = placement
    }

    public func selectedPlacement(in plan: TouchControlPlan) -> TouchControlPlacement? {
        plan.controls.first { $0.id == selectedID }
    }

    public func move(_ placement: TouchControlPlacement, by translation: CGSize) {
        select(placement)

        let start =
            movingFrom.flatMap { $0.id == placement.id ? $0.offset : nil }
            ?? adjustments.adjustment(for: placement.id).offset
        movingFrom = (placement.id, start)

        change {
            $0.controls[placement.id, default: .init()].offset = CGPoint(
                x: start.x + translation.width,
                y: start.y + translation.height
            )
        }
    }

    public func endMove() {
        movingFrom = nil
    }

    public func reset() {
        adjustments = TouchLayoutAdjustments()
        preferences.touchSticks = .init()
        select(nil)

        save()
    }

    public func plan(
        for metrics: TouchMetrics,
        in orientation: TouchOrientation
    ) -> TouchControlPlan {
        TouchLayoutPlanner(
            metrics: metrics,
            adjustments: adjustments(for: orientation),
            sticks: preferences.touchSticks
        )
        .plan(for: standard.layout.base)
    }

    private func adjustments(for orientation: TouchOrientation) -> TouchLayoutAdjustments {
        orientation == self.orientation
            ? adjustments : preferences.touchLayoutAdjustments(for: orientation)
    }
}

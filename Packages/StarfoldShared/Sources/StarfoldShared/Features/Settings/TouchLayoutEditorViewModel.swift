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
    public private(set) var selectedID: String?
    public private(set) var orientation: TouchOrientation = .landscape

    private let preferences: Preferences
    private let standard = StandardTouchLayout()

    private var adjustments = TouchLayoutAdjustments()
    private var movingFrom: CGPoint?

    public var opacity: Double {
        get { adjustments.opacity }
        set { change { $0.opacity = newValue } }
    }

    public var selectedScale: Double {
        get { selectedID.map { adjustments.adjustment(for: $0).scale } ?? 1 }
        set { changeSelected { $0.scale = newValue } }
    }

    public var scaleRange: ClosedRange<Double> {
        0.7...1.5
    }

    public var opacityRange: ClosedRange<Double> {
        0.3...1
    }

    public var hasSelection: Bool {
        selectedID != nil
    }

    init(preferences: Preferences) {
        self.preferences = preferences
        adjustments = preferences.touchLayoutAdjustments(for: orientation)
    }

    public func show(_ orientation: TouchOrientation) {
        guard orientation != self.orientation else { return }

        self.orientation = orientation
        adjustments = preferences.touchLayoutAdjustments(for: orientation)
        selectedID = nil
    }

    public func select(_ id: String?) {
        selectedID = id
    }

    public func move(_ id: String, by translation: CGSize) {
        selectedID = id

        let start = movingFrom ?? adjustments.adjustment(for: id).offset
        movingFrom = start

        change {
            $0.controls[id, default: .init()].offset = CGPoint(
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
        selectedID = nil

        save()
    }

    public func plan(for metrics: TouchMetrics) -> TouchControlPlan {
        TouchLayoutPlanner(metrics: metrics, adjustments: adjustments).plan(
            for: standard.layout.base
        )
    }

    private func changeSelected(_ update: (inout TouchControlAdjustment) -> Void) {
        guard let selectedID else { return }

        change { update(&$0.controls[selectedID, default: .init()]) }
    }

    private func change(_ update: (inout TouchLayoutAdjustments) -> Void) {
        update(&adjustments)

        save()
    }

    private func save() {
        preferences.setTouchLayoutAdjustments(adjustments, for: orientation)
    }
}

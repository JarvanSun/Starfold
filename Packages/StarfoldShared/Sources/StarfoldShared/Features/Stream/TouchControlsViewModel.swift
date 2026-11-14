//
//  TouchControlsViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Observation
import StreamKit
import XboxKit
import os

@Observable
public final class TouchControlsViewModel {
    private(set) var reference: TouchLayoutReference = .standard
    private var isHiddenByGame = false

    private var titleBundle: TouchBundle?
    private(set) var titleLayout: TouchLayout?

    private let controllers: ControllerHub
    private let preferences: Preferences
    private let standard = StandardTouchLayout()
    private let log = Logger(category: .stream)

    private var context = TouchContext()
    private var pendingPatches: [JSONPatch] = []

    public var isShowing: Bool {
        controllers.activeInput == .touch && !isHiddenByGame
    }

    public var isHapticsEnabled: Bool {
        preferences.isTouchHapticsEnabled
    }

    var isShowingTitleLayout: Bool {
        titleLayout != nil
    }

    init(controllers: ControllerHub, preferences: Preferences) {
        self.controllers = controllers
        self.preferences = preferences
    }

    public func reveal() {
        controllers.useTouchControls()
    }

    public func plan(for metrics: TouchMetrics, in orientation: TouchOrientation)
        -> TouchControlPlan
    {
        let standardAdjustments = preferences.touchLayoutAdjustments(for: orientation)

        switch titleLayout {
        case let layout?:
            let adjustments = TouchLayoutAdjustments(opacity: standardAdjustments.opacity)
            return TouchLayoutPlanner(metrics: metrics, adjustments: adjustments, sticks: .init())
                .plan(for: layout.base)
        case nil:
            return TouchLayoutPlanner(
                metrics: metrics,
                adjustments: standardAdjustments,
                sticks: preferences.touchSticks
            )
            .plan(for: standard.layout.base)
        }
    }

    func load(_ bundle: TouchBundle) {
        titleBundle = bundle
        context = pendingPatches.reduce(bundle.context) { applying($1, to: $0) }
        pendingPatches = []

        resolveTitleLayout()
    }

    func clearTitle() {
        titleBundle = nil
        titleLayout = nil
        context = TouchContext()
        pendingPatches = []
        reference = .standard
        isHiddenByGame = false
    }

    func apply(_ command: TouchControlsCommand) {
        switch command {
        case .showLayout(let reference, let patch): show(reference, patch: patch)
        case .patchState(let patch): applyPatch(patch)
        case .hide: isHiddenByGame = true
        }
    }

    private func show(_ reference: TouchLayoutReference, patch: Data?) {
        self.reference = reference
        isHiddenByGame = false

        switch patch {
        case let patch?: applyPatch(patch)
        case nil: resolveTitleLayout()
        }
    }

    private func applyPatch(_ data: Data) {
        do {
            let patch = try JSONDecoder().decode(JSONPatch.self, from: data)

            switch titleBundle {
            case nil: pendingPatches.append(patch)
            case _?: context = applying(patch, to: context)
            }
        } catch {
            log.error("Touch state patch could not be read: \(error)")
        }

        resolveTitleLayout()
    }

    private func applying(_ patch: JSONPatch, to context: TouchContext) -> TouchContext {
        do {
            return try context.applying(patch)
        } catch {
            log.error("Touch state patch was not applied: \(error)")
            return context
        }
    }

    private func resolveTitleLayout() {
        guard let titleBundle, let name = layoutName(in: titleBundle) else {
            titleLayout = nil
            return
        }

        do {
            let layout = try titleBundle.layout(
                named: name,
                locale: preferences.effectiveGameLanguage,
                context: context
            )
            titleLayout = isDrawable(layout) ? layout : nil
        } catch {
            log.error("Touch layout \(name) could not be shown: \(error)")
            titleLayout = nil
        }
    }

    private func isDrawable(_ layout: TouchLayout) -> Bool {
        let isDrawable = layout.base.isDrawable
        if !isDrawable { log.info("Touch layout uses controls without a Touch Controller match") }

        return isDrawable
    }

    private func layoutName(in bundle: TouchBundle) -> String? {
        switch reference {
        case .standard: nil
        case .titleDefault: bundle.manifest.defaultLayoutName ?? bundle.layoutNames.first
        case .named(let name): name
        }
    }
}

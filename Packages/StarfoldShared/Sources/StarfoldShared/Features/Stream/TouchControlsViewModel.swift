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
    private(set) var titleLayout: TouchLayout?

    private var titleID: String?
    private var title = TouchTitleState()
    private var otherTitles: [String: TouchTitleState] = [:]

    private let controllerHub: ControllerHub
    private let preferences: Preferences
    private let standard = StandardTouchLayout()
    private let log = Logger(category: .stream)

    var reference: TouchLayoutReference {
        title.reference
    }

    var titleBundleManifest: TouchBundleManifest? {
        title.bundle?.manifest
    }

    public var isShowing: Bool {
        controllerHub.activeInput == .touch && !title.isHiddenByGame
    }

    public var isHapticsEnabled: Bool {
        preferences.isTouchHapticsEnabled
    }

    var isShowingTitleLayout: Bool {
        titleLayout != nil
    }

    init(controllerHub: ControllerHub, preferences: Preferences) {
        self.controllerHub = controllerHub
        self.preferences = preferences
    }

    public func reveal() {
        controllerHub.useTouchControls()
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

    func isFocused(onTitle id: String) -> Bool {
        titleID == id
    }

    func focus(onTitle id: String) {
        guard id != titleID else { return }

        switch titleID {
        case let previous?:
            otherTitles[previous] = title
            title = otherTitles.removeValue(forKey: id) ?? TouchTitleState()
        case nil:
            break
        }
        titleID = id

        resolveTitleLayout()
    }

    private func resolveTitleLayout() {
        guard let titleBundle = title.bundle, let name = layoutName(in: titleBundle) else {
            titleLayout = nil
            return
        }

        do {
            let layout = try titleBundle.layout(
                named: name,
                locale: preferences.effectiveGameLanguage,
                context: title.context
            )
            titleLayout = isDrawable(layout) ? layout : nil
        } catch {
            log.error("Touch layout \(name) could not be shown: \(error)")
            titleLayout = nil
        }
    }

    private func layoutName(in bundle: TouchBundle) -> String? {
        switch title.reference {
        case .standard: nil
        case .titleDefault: bundle.manifest.defaultLayoutName ?? bundle.layoutNames.first
        case .named(let name): name
        }
    }

    private func isDrawable(_ layout: TouchLayout) -> Bool {
        let isDrawable = layout.base.isDrawable
        if !isDrawable { log.info("Touch layout uses controls without a Touch Controller match") }

        return isDrawable
    }

    func load(_ bundle: TouchBundle, forTitle id: String) {
        if id == titleID {
            title = loaded(bundle, into: title)
            resolveTitleLayout()
        } else {
            otherTitles[id] = loaded(bundle, into: otherTitles[id] ?? TouchTitleState())
        }
    }

    private func loaded(_ bundle: TouchBundle, into state: TouchTitleState) -> TouchTitleState {
        var state = state
        state.bundle = bundle
        state.context = state.pendingPatches.reduce(bundle.context) { applying($1, to: $0) }
        state.pendingPatches = []
        return state
    }

    private func applying(_ patch: JSONPatch, to context: TouchContext) -> TouchContext {
        do {
            return try context.applying(patch)
        } catch {
            log.error("Touch state patch was not applied: \(error)")
            return context
        }
    }

    func apply(_ command: TouchControlsCommand) {
        switch command {
        case .showLayout(let reference, let patch): show(reference, patch: patch)
        case .patchState(let patch): applyPatch(patch)
        case .hide: title.isHiddenByGame = true
        }
    }

    private func show(_ reference: TouchLayoutReference, patch: Data?) {
        title.reference = reference
        title.isHiddenByGame = false

        switch patch {
        case let patch?: applyPatch(patch)
        case nil: resolveTitleLayout()
        }
    }

    private func applyPatch(_ data: Data) {
        do {
            let patch = try JSONDecoder().decode(JSONPatch.self, from: data)

            switch title.bundle {
            case nil: title.pendingPatches.append(patch)
            case _?: title.context = applying(patch, to: title.context)
            }
        } catch {
            log.error("Touch state patch could not be read: \(error)")
        }

        resolveTitleLayout()
    }
}

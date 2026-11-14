//
//  TouchControllerView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import MetalKit
import StarfoldShared
import TouchController
import UIKit

final class TouchControllerView: MTKView {
    private struct TrackedTouch {
        let index: Int
        var point: CGPoint
    }

    var stickPassThroughZone: CGSize = .zero

    private let commandQueue: MTLCommandQueue?
    private let pressFeedback = UIImpactFeedbackGenerator(style: .light)

    private var isHapticsEnabled = false
    private var touchController: TCTouchController?
    private var touches: [ObjectIdentifier: TrackedTouch] = [:]
    private var controlPlan: TouchControlPlan?
    private var placedControls: [String: TCControlLayout] = [:]

    init() {
        let device = MTLCreateSystemDefaultDevice()
        commandQueue = device?.makeCommandQueue()

        super.init(frame: .zero, device: device)

        isOpaque = false
        backgroundColor = .clear
        clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        isMultipleTouchEnabled = true
        preferredFramesPerSecond = 60
        delegate = self
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func show(_ controlPlan: TouchControlPlan) {
        guard controlPlan != self.controlPlan else { return }

        let previous = self.controlPlan
        self.controlPlan = controlPlan
        alpha = controlPlan.opacity

        switch previous.map(controlPlan.isRearrangement(of:)) {
        case true?: move(to: controlPlan)
        case false?, nil: rebuild(controlPlan)
        }
    }

    private func move(to controlPlan: TouchControlPlan) {
        for placement in controlPlan.controls {
            placedControls[placement.id]?.offset = placement.offset
        }
        touchController?.size = bounds.size
        draw()
    }

    private func rebuild(_ controlPlan: TouchControlPlan) {
        let controller = connectedController()
        for touch in touches.values {
            _ = controller.handleTouchEnded(at: touch.point, index: touch.index)
        }
        controller.removeAllControls()

        let builder = TouchControlBuilder(controller: controller, sticks: controlPlan.sticks)
        placedControls = [:]
        for placement in controlPlan.controls {
            placedControls[placement.id] = builder.add(placement)
        }

        for touch in touches.values {
            _ = controller.handleTouchBegan(at: touch.point, index: touch.index)
        }
    }

    private func connectedController() -> TCTouchController {
        touchController ?? makeController()
    }

    private func makeController() -> TCTouchController {
        let controller = TCTouchController(descriptor: TCTouchControllerDescriptor(mtkView: self))
        controller.connect()
        touchController = controller
        return controller
    }

    func apply(_ mode: TouchControlsMode) {
        isPaused = mode == .hidden
        isHidden = mode == .hidden
        presentsWithTransaction = mode == .preview

        switch mode {
        case .playing(let isHapticsEnabled):
            isUserInteractionEnabled = true
            self.isHapticsEnabled = isHapticsEnabled
        case .hidden, .preview:
            isUserInteractionEnabled = false
            isHapticsEnabled = false
            releaseAllTouches()
        }
    }

    private func releaseAllTouches() {
        for touch in touches.values {
            _ = touchController?.handleTouchEnded(at: touch.point, index: touch.index)
        }

        touches.removeAll()
    }

    func disconnect() {
        touchController?.disconnect()
        touchController = nil
        controlPlan = nil
        placedControls = [:]
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        switch touchController?.control(at: point) {
        case nil: false
        case is TCThumbstick: !isInStickPassThroughZone(point)
        case _?: true
        }
    }

    private func isInStickPassThroughZone(_ point: CGPoint) -> Bool {
        let zone = CGRect(
            x: bounds.midX - stickPassThroughZone.width / 2,
            y: bounds.minY,
            width: stickPassThroughZone.width,
            height: stickPassThroughZone.height
        )
        return zone.contains(point)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let tracked = TrackedTouch(index: nextFreeIndex(), point: touch.location(in: self))
            self.touches[ObjectIdentifier(touch)] = tracked

            let isOnControl =
                touchController?.handleTouchBegan(at: tracked.point, index: tracked.index) ?? false
            if isOnControl { tapFeedback() }
        }
    }

    private func nextFreeIndex() -> Int {
        let used = Set(touches.values.map(\.index))
        return (0...).first { !used.contains($0) } ?? 0
    }

    private func tapFeedback() {
        guard isHapticsEnabled else { return }

        pressFeedback.impactOccurred()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            guard let index = self.touches[ObjectIdentifier(touch)]?.index else { continue }

            self.touches[ObjectIdentifier(touch)]?.point = point
            _ = touchController?.handleTouchMoved(at: point, index: index)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        end(touches)
    }

    private func end(_ touches: Set<UITouch>) {
        for touch in touches {
            guard let tracked = self.touches.removeValue(forKey: ObjectIdentifier(touch)) else {
                continue
            }

            _ = touchController?.handleTouchEnded(
                at: touch.location(in: self),
                index: tracked.index
            )
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        end(touches)
    }
}

// MARK: - MTKViewDelegate

extension TouchControllerView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        touchController?.size = bounds.size
        touchController?.drawableSize = size
    }

    func draw(in view: MTKView) {
        guard let touchController,
            let pass = currentRenderPassDescriptor,
            let drawable = currentDrawable,
            let commands = commandQueue?.makeCommandBuffer(),
            let encoder = commands.makeRenderCommandEncoder(descriptor: pass)
        else { return }

        touchController.render(using: encoder)
        encoder.endEncoding()

        switch presentsWithTransaction {
        case true:
            commands.commit()
            commands.waitUntilScheduled()
            drawable.present()
        case false:
            commands.present(drawable)
            commands.commit()
        }
    }
}

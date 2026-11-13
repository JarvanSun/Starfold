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
    var isHapticsEnabled = false

    private let commandQueue: MTLCommandQueue?
    private let pressFeedback = UIImpactFeedbackGenerator(style: .light)

    private var touchController: TCTouchController?
    private var touchIndices: [ObjectIdentifier: Int] = [:]
    private var plan: TouchControlPlan?

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

    func show(_ plan: TouchControlPlan) {
        guard plan != self.plan else { return }

        self.plan = plan
        alpha = plan.opacity

        let controller = connectedController()
        controller.removeAllControls()

        for placement in plan.controls {
            TouchControlBuilder(controller: controller).add(placement)
        }
    }

    func setActive(_ isActive: Bool) {
        isPaused = !isActive
        isHidden = !isActive
        isUserInteractionEnabled = isActive

        if !isActive { releaseAllTouches() }
    }

    func disconnect() {
        touchController?.disconnect()
        touchController = nil
        plan = nil
    }

    private func connectedController() -> TCTouchController {
        switch touchController {
        case let controller?: return controller
        case nil: return makeController()
        }
    }

    private func makeController() -> TCTouchController {
        let controller = TCTouchController(descriptor: TCTouchControllerDescriptor(mtkView: self))
        controller.connect()
        touchController = controller
        return controller
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        touchController?.control(at: point) != nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let index = nextFreeIndex()
            touchIndices[ObjectIdentifier(touch)] = index

            let isOnControl =
                touchController?.handleTouchBegan(at: touch.location(in: self), index: index)
                ?? false
            if isOnControl { tapFeedback() }
        }
    }

    private func nextFreeIndex() -> Int {
        let used = Set(touchIndices.values)
        return (0...).first { !used.contains($0) } ?? 0
    }

    private func tapFeedback() {
        guard isHapticsEnabled else { return }

        pressFeedback.impactOccurred()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let index = touchIndices[ObjectIdentifier(touch)] else { continue }

            _ = touchController?.handleTouchMoved(at: touch.location(in: self), index: index)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        end(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        end(touches)
    }

    private func end(_ touches: Set<UITouch>) {
        for touch in touches {
            guard let index = touchIndices.removeValue(forKey: ObjectIdentifier(touch)) else {
                continue
            }

            _ = touchController?.handleTouchEnded(at: touch.location(in: self), index: index)
        }
    }

    private func releaseAllTouches() {
        for index in touchIndices.values {
            _ = touchController?.handleTouchEnded(at: .zero, index: index)
        }

        touchIndices.removeAll()
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

        commands.present(drawable)
        commands.commit()
    }
}

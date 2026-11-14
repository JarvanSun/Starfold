//
//  TouchControlBuilder.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import StarfoldShared
import StreamKit
import TouchController

struct TouchControlBuilder {
    let controller: TCTouchController
    let sticks: TouchSticks

    func add(_ placement: TouchControlPlacement) -> TCControlLayout? {
        guard sticks.visibility(of: placement.input) != .off else { return nil }

        return switch placement.input {
        case .leftStick: addThumbstick(placement, label: .leftThumbstick, collider: .leftSide)
        case .rightStick: addThumbstick(placement, label: .rightThumbstick, collider: .rightSide)
        case .directionPad: addDirectionPad(placement)
        case .leftTrigger: addButton(placement, label: .buttonLeftTrigger, shape: .rect)
        case .rightTrigger: addButton(placement, label: .buttonRightTrigger, shape: .rect)
        case .button(let button):
            addButton(placement, label: button.controlLabel, shape: button.controlShape)
        }
    }

    private func addThumbstick(
        _ placement: TouchControlPlacement,
        label: TCControlLabel,
        collider: TCColliderShape
    ) -> TCControlLayout {
        let stickScale: CGFloat = 0.45
        let size = square(placement.diameter)
        let stickSize = square(placement.diameter * stickScale)

        let descriptor = TCThumbstickDescriptor()
        descriptor.label = label
        descriptor.size = size
        descriptor.stickSize = stickSize
        descriptor.colliderShape = collider
        descriptor.hidesWhenNotPressed = sticks.visibility(of: placement.input) == .onTouch
        descriptor.backgroundContents = .thumbstickStickBackgroundContents(
            size: size,
            controller: controller
        )
        descriptor.stickContents = .thumbstickStickContents(size: stickSize, controller: controller)

        return place(controller.addThumbstick(descriptor: descriptor), at: placement)
    }

    private func square(_ length: CGFloat) -> CGSize {
        CGSize(width: length, height: length)
    }

    private func place(_ control: TCControlLayout, at placement: TouchControlPlacement)
        -> TCControlLayout
    {
        control.anchor = placement.anchor.layoutAnchor
        control.anchorCoordinateSystem = .absolute
        control.offset = placement.offset
        control.zIndex = placement.input.controlLayer
        return control
    }

    private func addDirectionPad(_ placement: TouchControlPlacement) -> TCControlLayout {
        let elementScale: CGFloat = 0.36
        let label = TCControlLabel.directionPad
        let size = square(placement.diameter)
        let element = square(placement.diameter * elementScale)

        let descriptor = TCDirectionPadDescriptor()
        descriptor.compositeLabel = label
        descriptor.size = size
        descriptor.upContents = directionContents(label, size: element, direction: .up)
        descriptor.downContents = directionContents(label, size: element, direction: .down)
        descriptor.leftContents = directionContents(label, size: element, direction: .left)
        descriptor.rightContents = directionContents(label, size: element, direction: .right)

        return place(controller.addDirectionPad(descriptor: descriptor), at: placement)
    }

    private func directionContents(
        _ label: TCControlLabel,
        size: CGSize,
        direction: TCControlContents.DpadDirection
    ) -> TCControlContents {
        .directionPadContents(
            label: label,
            size: size,
            style: .circle,
            direction: direction,
            controller: controller
        )
    }

    private func addButton(
        _ placement: TouchControlPlacement,
        label: TCControlLabel?,
        shape: TCControlContents.ButtonShape
    ) -> TCControlLayout? {
        guard let label else { return nil }

        let size = square(placement.diameter)

        let descriptor = TCButtonDescriptor()
        descriptor.label = label
        descriptor.size = size
        descriptor.contents = .buttonContents(
            forSystemImageNamed: placement.symbol,
            size: size,
            shape: shape,
            controller: controller
        )

        return place(controller.addButton(descriptor: descriptor), at: placement)
    }
}

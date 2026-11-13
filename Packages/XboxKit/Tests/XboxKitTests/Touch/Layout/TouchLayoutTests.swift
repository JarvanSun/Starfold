//
//  TouchLayoutTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct TouchLayoutTests {
    @Test
    func initThenPlacesTheStandardControllerLikeAGamepad() throws {
        // Given / When
        let layout = try TouchLayout(
            json: Data(String.dummyStandardControllerLayout.utf8),
            context: .init()
        )

        // Then
        let leftStick = TouchControl(
            kind: .joystick(
                .init(
                    axes: [
                        .init(
                            input: .xy,
                            output: .gamepad(.leftJoystick),
                            deadzone: .init(threshold: 0.05, isRadial: true)
                        )
                    ],
                    shouldExpand: false
                )
            )
        )
        let rightStick = TouchControl(
            kind: .joystick(
                .init(
                    axes: [
                        .init(
                            input: .xy,
                            output: .gamepad(.rightJoystick),
                            deadzone: .init(threshold: 0.05, isRadial: true)
                        )
                    ]
                )
            )
        )
        let expected = TouchLayer(
            left: .init(
                inner: [.control(leftStick)],
                outer: [
                    .empty, .empty, .cluster([TouchControl(kind: .directionalPad(.init()))]),
                    button(.leftThumb), .empty, button(.leftTrigger), button(.leftBumper),
                ]
            ),
            right: .init(
                inner: [
                    button(.gamepadY), button(.gamepadB), button(.gamepadA), button(.gamepadX),
                ],
                outer: [
                    button(.rightBumper), button(.rightTrigger), .empty, button(.rightThumb),
                    .cluster([rightStick]),
                ]
            ),
            upper: .init(right: [button(.menu), button(.view)])
        )
        #expect(layout == TouchLayout(base: expected))
    }

    @Test
    func initThenReadsTheFirstPersonShooterSample() throws {
        // Given / When
        let layout = try TouchLayout(
            json: Data(String.dummyFirstPersonShooterLayout.utf8),
            context: .init()
        )

        // Then
        let lookPad = Touchpad(
            axes: [
                .init(input: .x, output: .relativeMouse(.horizontal), sensitivity: 5),
                .init(input: .y, output: .relativeMouse(.vertical), sensitivity: 2.5),
            ]
        )
        let gyroscope = TouchSensor(
            kind: .gyroscope,
            axes: [.init(input: .xy, output: .relativeMouse(.movement), sensitivity: 8)]
        )
        guard case .control(let look)? = layout.base.right.inner.first,
            case .cluster(let fireCluster)? = layout.base.right.outer.dropFirst(3).first,
            case .touchpad(let fire)? = fireCluster.first??.kind
        else {
            Issue.record("Unexpected right wheel \(layout.base.right)")
            return
        }
        #expect(look.kind == .touchpad(lookPad))
        #expect(look.styles[.default]?.faceImage?.source == .icon("look", showsActionLabel: true))
        #expect(fire.isRenderedAsButton)
        #expect(
            fire.actions == [.output(.gamepad(.rightTrigger)), .output(.gamepad(.leftTrigger))]
        )
        #expect(layout.base.sensors == [gyroscope])
    }

    @Test
    func initThenResolvesReferencesLayersAndPalettes() throws {
        // Given
        let members = try JSONFixtureDecoder().decode(
            [String: JSONValue].self,
            from: .dummyLayeredContext
        )

        // When
        let layout = try TouchLayout(
            json: Data(String.dummyLayeredLayout.utf8),
            context: .init(members: members)
        )

        // Then
        let weaponLayer = try #require(layout.layers["WeaponLayer"])
        let throttle = TouchThrottle(
            upOutput: .gamepad(.rightTrigger),
            downOutput: .gamepad(.leftTrigger),
            isSticky: true
        )
        guard case .control(let moveStick)? = layout.base.left.inner.first,
            case .control(let weaponButton)? = layout.base.right.inner.first
        else {
            Issue.record("Unexpected base layer \(layout.base)")
            return
        }
        #expect(
            moveStick.styles[.default]?.knob?.faceImage?.source
                == .icon("walk", showsActionLabel: true)
        )
        #expect(!weaponButton.isVisible)
        #expect(weaponButton.kind == .button(.init(actions: [.layer("WeaponLayer")])))
        #expect(
            layout.base.right.inner[2] == .control(.init(kind: .unsupported(type: "steeringWheel")))
        )
        #expect(
            weaponLayer.right.outer == [
                .cluster([TouchControl(kind: .throttle(throttle)), nil]),
                .control(.init(kind: .blank)),
            ]
        )
        #expect(weaponLayer.sensors.first??.kind == .gyroscope)
        #expect(
            layout.palette["system_accentPrimary"]
                == .rgba(red: 30 / 255, green: 144 / 255, blue: 1, alpha: 1)
        )
        #expect(
            layout.highContrastPalette["system_accentPrimary"]
                == .rgba(red: 1, green: 1, blue: 1, alpha: 1)
        )
    }

    @Test
    func initWhenAReferenceCannotBeResolvedThenThrows() {
        // Given
        let json = ##"{"content":{"upper":{"right":[{"$ref":"#/definitions/missing"}]}}}"##

        // When / Then
        #expect(throws: TouchLayoutError.unresolvedReference("#/definitions/missing")) {
            try TouchLayout(json: Data(json.utf8), context: .init())
        }
    }

    @Test
    func initWhenContentIsMissingThenThrowsInvalidLayout() {
        // Given
        let json = #"{"styles":{}}"#

        // When
        let error = #expect(throws: TouchLayoutError.self) {
            try TouchLayout(json: Data(json.utf8), context: .init())
        }

        // Then
        switch error {
        case .invalidLayout?: break
        default: Issue.record("Expected invalidLayout, got \(String(describing: error))")
        }
    }
}

private extension TouchLayoutTests {
    func button(_ output: TouchGamepadOutput) -> TouchSlot {
        .control(.init(kind: .button(.init(actions: [.output(.gamepad(output))]))))
    }
}

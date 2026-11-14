//
//  ControllerHub.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreHaptics
import Foundation
import GameController
import Observation
import os

@MainActor
@Observable
public final class ControllerHub {
    public let gamepadRouter: GamepadRouter
    public let xboxButtonSettings: XboxButtonSettings

    public var isDeviceRumbleEnabled = false

    public private(set) var connectedControllers: [ConnectedController] = []
    public private(set) var isRoutingToGame: Bool
    public private(set) var activeInput: ActiveInput = .touch

    private let inputDestination: ControllerInputDestination
    private let inputQueue: DispatchQueue
    private let touchControllerCategory: String?
    private let log = Logger(category: .controllers)

    private var controllerSlots: [ObjectIdentifier: UInt8] = [:]
    private var touchControllerID: ObjectIdentifier?
    private var rumblePlayers: [ObjectIdentifier: RumblePlayer] = [:]
    private var deviceRumble: RumblePlayer?
    private var observers: [NSObjectProtocol] = []

    public init(controllerRouting: ControllerRouting, touchControllerCategory: String? = nil) {
        let gamepadRouter = GamepadRouter(controllerRouting: controllerRouting)
        let inputQueue = DispatchQueue(label: "StreamKit.controllers", qos: .userInteractive)
        self.gamepadRouter = gamepadRouter
        xboxButtonSettings = XboxButtonSettings()
        self.inputQueue = inputQueue
        self.touchControllerCategory = touchControllerCategory

        switch controllerRouting {
        case .direct:
            inputDestination = .router(gamepadRouter)
            isRoutingToGame = true
        case .gated:
            inputDestination = .gated(
                GatedControllerInput(inputQueue: inputQueue, gamepadRouter: gamepadRouter)
            )
            isRoutingToGame = false
        }

        GCController.shouldMonitorBackgroundEvents = true

        observeActiveInput()

        observeConnections()

        syncControllers()

        GCController.startWirelessControllerDiscovery {}
    }

    private func observeActiveInput() {
        gamepadRouter.setActiveInputHandler { [weak self] input in
            DispatchQueue.main.async {
                MainActor.assumeIsolated { self?.activeInput = input }
            }
        }
    }

    private func observeConnections() {
        for name in [Notification.Name.GCControllerDidConnect, .GCControllerDidDisconnect] {
            let observer = NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.syncControllers() }
            }
            observers.append(observer)
        }
    }

    private func syncControllers() {
        let current = GCController.controllers()
        let currentIDs = Set(current.map(ObjectIdentifier.init))

        for id in controllerSlots.keys where !currentIDs.contains(id) {
            detach(id)
        }

        if let touchControllerID, !currentIDs.contains(touchControllerID) {
            detachTouchController()
        }

        for controller in current {
            attach(controller)
        }

        xboxButtonSettings.setControllerConnected(!controllerSlots.isEmpty)
    }

    private func detach(_ id: ObjectIdentifier) {
        guard let slot = controllerSlots.removeValue(forKey: id) else { return }

        rumblePlayers[id]?.stop()
        rumblePlayers[id] = nil

        connectedControllers.removeAll { $0.id == id }

        let inputDestination = inputDestination
        inputQueue.async {
            inputDestination.update(slot: slot, state: nil)
        }

        if controllerSlots.isEmpty {
            gamepadRouter.use(.touch)
        }
    }

    private func detachTouchController() {
        touchControllerID = nil

        let inputDestination = inputDestination
        inputQueue.async {
            inputDestination.updateTouch(nil)
        }
    }

    private func attach(_ controller: GCController) {
        let isTouchController = controller.productCategory == touchControllerCategory

        switch isTouchController {
        case true: attachTouchController(controller)
        case false: attachPhysicalController(controller)
        }
    }

    private func attachTouchController(_ controller: GCController) {
        let id = ObjectIdentifier(controller)
        guard touchControllerID != id else { return }

        touchControllerID = id

        controller.handlerQueue = inputQueue

        let profile = controller.physicalInputProfile
        let inputDestination = inputDestination
        profile.valueDidChangeHandler = { @Sendable profile, _ in
            inputDestination.updateTouch(GamepadState(reading: profile))
        }

        nonisolated(unsafe) let initialProfile = profile
        inputQueue.async {
            inputDestination.attachTouch(initialProfile)
        }

        log.info("Touch controller attached to slot 0")
    }

    private func attachPhysicalController(_ controller: GCController) {
        let id = ObjectIdentifier(controller)
        guard let gamepad = controller.extendedGamepad,
            controllerSlots[id] == nil,
            let slot = freeSlot()
        else { return }

        controllerSlots[id] = slot

        startReading(gamepad, of: controller, slot: slot)

        if let player = RumblePlayer(controller: controller) {
            rumblePlayers[id] = player
        }

        listConnected(controller, slot: slot)

        deviceRumble?.stop()

        gamepadRouter.use(.controller)

        log.info("Controller \(controller.vendorName ?? "?") → slot \(slot)")
    }

    private func freeSlot() -> UInt8? {
        let used = Set(controllerSlots.values)
        let slotCount: UInt8 = 4

        return (0..<slotCount).first { !used.contains($0) }
    }

    private func startReading(
        _ gamepad: GCExtendedGamepad,
        of controller: GCController,
        slot: UInt8
    ) {
        inputDestination.prepare(gamepad)

        controller.handlerQueue = inputQueue

        let inputDestination = inputDestination
        gamepad.valueChangedHandler = { @Sendable gamepad, _ in
            inputDestination.update(slot: slot, state: GamepadState(reading: gamepad))
        }

        nonisolated(unsafe) let initialGamepad = gamepad
        inputQueue.async {
            inputDestination.attach(slot: slot, gamepad: initialGamepad)
        }
    }

    private func listConnected(_ controller: GCController, slot: UInt8) {
        let entry = ConnectedController(
            id: ObjectIdentifier(controller),
            slot: slot,
            name: controller.vendorName ?? "Controller",
            batteryLevel: controller.battery?.batteryLevel
        )
        connectedControllers.append(entry)
        connectedControllers.sort { $0.slot < $1.slot }
    }

    public func checkControllers() {
        syncControllers()
    }

    public func routeInput(toGame isPlaying: Bool) {
        guard case .gated(let input) = inputDestination else { return }

        isRoutingToGame = isPlaying

        if !isPlaying {
            stopRumble()
        }

        input.setPlaying(isPlaying)
    }

    public func useTouchControls() {
        gamepadRouter.use(.touch)
    }

    public func playRumble(_ effect: VibrationEffect) {
        let target = RumbleTarget(
            effect: effect,
            controllerSlots: Set(controllerSlots.values),
            isDeviceRumbleEnabled: isDeviceRumbleEnabled
        )

        switch target {
        case .controllers(let slot): playOnControllers(effect, slot: slot)
        case .device: deviceRumblePlayer()?.play(effect)
        case .nowhere: break
        }
    }

    private func playOnControllers(_ effect: VibrationEffect, slot: UInt8) {
        for (id, controllerSlot) in controllerSlots where controllerSlot == slot {
            rumblePlayers[id]?.play(effect)
        }
    }

    private func deviceRumblePlayer() -> RumblePlayer? {
        if deviceRumble == nil {
            deviceRumble = RumblePlayer(device: CHHapticEngine.capabilitiesForHardware())
        }

        return deviceRumble
    }

    public func testRumble(slot: UInt8) {
        let effect = VibrationEffect(
            gamepadIndex: slot,
            leftMotor: 0.8,
            rightMotor: 0.6,
            leftTrigger: 0.4,
            rightTrigger: 0.4,
            duration: .milliseconds(400)
        )
        playRumble(effect)
    }

    public func stopRumble() {
        for player in rumblePlayers.values {
            player.stop()
        }

        deviceRumble?.stop()
    }
}

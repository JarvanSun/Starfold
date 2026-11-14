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
    public let router: GamepadRouter
    public let xboxButton: XboxButtonSettings

    public var isDeviceRumbleEnabled = false

    public private(set) var connected: [ConnectedController] = []
    public private(set) var isRoutingToGame: Bool
    public private(set) var activeInput: ActiveInput = .touch

    private let destination: ControllerInputDestination
    private let inputQueue: DispatchQueue
    private let touchControllerCategory: String?
    private let log = Logger(category: .controllers)

    private var slots: [ObjectIdentifier: UInt8] = [:]
    private var touchControllerID: ObjectIdentifier?
    private var rumblePlayers: [ObjectIdentifier: RumblePlayer] = [:]
    private var deviceRumble: RumblePlayer?
    private var observers: [NSObjectProtocol] = []

    public init(routing: ControllerRouting, touchControllerCategory: String? = nil) {
        let router = GamepadRouter(routing: routing)
        let inputQueue = DispatchQueue(label: "StreamKit.controllers", qos: .userInteractive)
        self.router = router
        xboxButton = XboxButtonSettings()
        self.inputQueue = inputQueue
        self.touchControllerCategory = touchControllerCategory

        switch routing {
        case .direct:
            destination = .router(router)
            isRoutingToGame = true
        case .gated:
            destination = .gated(GatedControllerInput(queue: inputQueue, router: router))
            isRoutingToGame = false
        }

        GCController.shouldMonitorBackgroundEvents = true

        observeActiveInput()

        observeConnections()

        syncControllers()

        GCController.startWirelessControllerDiscovery {}
    }

    private func observeActiveInput() {
        router.setActiveInputHandler { [weak self] input in
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

        for id in slots.keys where !currentIDs.contains(id) {
            detach(id)
        }

        if let touchControllerID, !currentIDs.contains(touchControllerID) {
            detachTouchController()
        }

        for controller in current {
            attach(controller)
        }

        xboxButton.setControllerConnected(!slots.isEmpty)
    }

    private func detach(_ id: ObjectIdentifier) {
        guard let slot = slots.removeValue(forKey: id) else { return }

        rumblePlayers[id]?.stop()
        rumblePlayers[id] = nil

        connected.removeAll { $0.id == id }

        let destination = destination
        inputQueue.async {
            destination.update(slot: slot, state: nil)
        }

        if slots.isEmpty {
            router.use(.touch)
        }
    }

    private func detachTouchController() {
        touchControllerID = nil

        let destination = destination
        inputQueue.async {
            destination.updateTouch(nil)
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
        let destination = destination
        profile.valueDidChangeHandler = { @Sendable profile, _ in
            destination.updateTouch(GamepadState(reading: profile))
        }

        nonisolated(unsafe) let initialProfile = profile
        inputQueue.async {
            destination.attachTouch(initialProfile)
        }

        log.info("Touch controller attached to slot 0")
    }

    private func attachPhysicalController(_ controller: GCController) {
        let id = ObjectIdentifier(controller)
        guard let gamepad = controller.extendedGamepad,
            slots[id] == nil,
            let slot = freeSlot()
        else { return }

        slots[id] = slot

        startReading(gamepad, of: controller, slot: slot)

        if let player = RumblePlayer(controller: controller) {
            rumblePlayers[id] = player
        }

        listConnected(controller, slot: slot)

        deviceRumble?.stop()

        router.use(.controller)

        log.info("Controller \(controller.vendorName ?? "?") → slot \(slot)")
    }

    private func freeSlot() -> UInt8? {
        let used = Set(slots.values)
        let slotCount: UInt8 = 4

        return (0..<slotCount).first { !used.contains($0) }
    }

    private func startReading(
        _ gamepad: GCExtendedGamepad,
        of controller: GCController,
        slot: UInt8
    ) {
        destination.prepare(gamepad)

        controller.handlerQueue = inputQueue

        let destination = destination
        gamepad.valueChangedHandler = { @Sendable gamepad, _ in
            destination.update(slot: slot, state: GamepadState(reading: gamepad))
        }

        nonisolated(unsafe) let initialGamepad = gamepad
        inputQueue.async {
            destination.attach(slot: slot, gamepad: initialGamepad)
        }
    }

    private func listConnected(_ controller: GCController, slot: UInt8) {
        let entry = ConnectedController(
            id: ObjectIdentifier(controller),
            slot: slot,
            name: controller.vendorName ?? "Controller",
            batteryLevel: controller.battery?.batteryLevel
        )
        connected.append(entry)
        connected.sort { $0.slot < $1.slot }
    }

    public func checkControllers() {
        syncControllers()
    }

    public func routeInput(toGame isPlaying: Bool) {
        guard case .gated(let input) = destination else { return }

        isRoutingToGame = isPlaying

        if !isPlaying {
            stopRumble()
        }

        input.setPlaying(isPlaying)
    }

    public func useTouchControls() {
        router.use(.touch)
    }

    public func playRumble(_ effect: VibrationEffect) {
        let target = RumbleTarget(
            effect: effect,
            controllerSlots: Set(slots.values),
            isDeviceRumbleEnabled: isDeviceRumbleEnabled
        )

        switch target {
        case .controllers(let slot): playOnControllers(effect, slot: slot)
        case .device: deviceRumblePlayer()?.play(effect)
        case .nowhere: break
        }
    }

    private func playOnControllers(_ effect: VibrationEffect, slot: UInt8) {
        for (id, controllerSlot) in slots where controllerSlot == slot {
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

//
//  ControllerHub.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import GameController
import Observation
import os

@MainActor
@Observable
public final class ControllerHub {
    public let router: GamepadRouter
    public let xboxButton: XboxButtonSettings

    public private(set) var connected: [ConnectedController] = []
    public private(set) var isRoutingToGame: Bool

    private let destination: ControllerInputDestination
    private let inputQueue: DispatchQueue
    private let log = Logger(category: .controllers)

    private var slots: [ObjectIdentifier: UInt8] = [:]
    private var rumblePlayers: [ObjectIdentifier: RumblePlayer] = [:]
    private var observers: [NSObjectProtocol] = []

    public init(routing: ControllerRouting) {
        let router = GamepadRouter(routing: routing)
        let inputQueue = DispatchQueue(label: "StreamKit.controllers", qos: .userInteractive)
        self.router = router
        xboxButton = XboxButtonSettings()
        self.inputQueue = inputQueue

        switch routing {
        case .direct:
            destination = .router(router)
            isRoutingToGame = true
        case .television:
            destination = .television(TVControllerInput(queue: inputQueue, router: router))
            isRoutingToGame = false
        }

        GCController.shouldMonitorBackgroundEvents = true

        observeConnections()

        syncControllers()

        GCController.startWirelessControllerDiscovery {}
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
    }

    private func attach(_ controller: GCController) {
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
        guard case .television(let input) = destination else { return }

        isRoutingToGame = isPlaying

        if !isPlaying {
            stopRumble()
        }

        input.setPlaying(isPlaying)
    }

    public func playRumble(_ effect: VibrationEffect) {
        for controller in GCController.controllers()
        where slots[ObjectIdentifier(controller)] == effect.gamepadIndex {
            rumblePlayers[ObjectIdentifier(controller)]?.play(effect)
        }
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
    }
}

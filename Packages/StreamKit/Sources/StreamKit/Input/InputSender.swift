//
//  InputSender.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation
import QuartzCore

final class InputSender: @unchecked Sendable {
    private let state: InputState
    private let clockOrigin: CFTimeInterval
    private let condition = NSCondition()
    private let sendLock = NSLock()

    private var isSignalled = false
    private var isRunning = false
    private var peer: PeerConnection?
    private var sequence: UInt32 = 1
    private var announced: Set<UInt8> = []

    init(state: InputState, clockOrigin: CFTimeInterval) {
        self.state = state
        self.clockOrigin = clockOrigin

        state.setChangeHandler { [weak self] in self?.signal() }
    }

    func start(peer: PeerConnection, announced: Set<UInt8>) {
        sendLock.withLock { self.announced = announced }

        condition.withLock {
            self.peer = peer

            guard !isRunning else { return }

            isRunning = true

            let thread = Thread { [self] in run() }
            thread.name = "Starfold input"
            thread.qualityOfService = .userInteractive
            thread.start()
        }
    }

    private func run() {
        let idleWakeInterval: TimeInterval = 0.008

        while true {
            condition.lock()

            if isRunning, !isSignalled {
                _ = condition.wait(until: Date(timeIntervalSinceNow: idleWakeInterval))
            }

            isSignalled = false

            let peer = isRunning ? self.peer : nil
            let isStillRunning = isRunning

            condition.unlock()

            guard isStillRunning else { return }

            if let peer {
                sendLock.withLock { send(on: peer) }
            }
        }
    }

    private func send(on peer: PeerConnection) {
        let maximumQueuedBytes: UInt64 = 4096

        guard peer.bufferedAmount(on: .input) < maximumQueuedBytes else { return }

        let timestamp = (CACurrentMediaTime() - clockOrigin) * 1000
        let snapshot = state.drain(now: timestamp)
        announce(snapshot.addedPads, on: peer)

        withdraw(snapshot.removedPads, on: peer)

        guard let packet = snapshot.report.encoded(sequence: sequence, timestamp: timestamp) else {
            return
        }

        if peer.send(packet, on: .input) {
            sequence &+= 1
        }
    }

    private func announce(_ addedPads: [UInt8], on peer: PeerConnection) {
        for index in addedPads where !announced.contains(index) {
            peer.send(
                ControlMessage.gamepadChanged(index: Int(index), isAdded: true).json,
                on: .control
            )

            announced.insert(index)
        }
    }

    private func withdraw(_ removedPads: [UInt8], on peer: PeerConnection) {
        for index in removedPads where announced.contains(index) && index != 0 {
            peer.send(
                ControlMessage.gamepadChanged(index: Int(index), isAdded: false).json,
                on: .control
            )

            announced.remove(index)
        }
    }

    func stop() -> Set<UInt8> {
        condition.withLock {
            isRunning = false
            peer = nil

            condition.signal()
        }

        return sendLock.withLock { announced }
    }

    private func signal() {
        condition.withLock {
            isSignalled = true

            condition.signal()
        }
    }

}

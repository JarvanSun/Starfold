//
//  InputSender.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation
import QuartzCore

final class InputSender: @unchecked Sendable {
    private let inputState: InputState
    private let clockOrigin: CFTimeInterval
    private let condition = NSCondition()
    private let sendLock = NSLock()

    private var isSignalled = false
    private var isRunning = false
    private var peerConnection: PeerConnection?
    private var sequenceNumber: UInt32 = 1
    private var announcedPads: Set<UInt8> = []

    init(inputState: InputState, clockOrigin: CFTimeInterval) {
        self.inputState = inputState
        self.clockOrigin = clockOrigin

        inputState.setChangeHandler { [weak self] in self?.signal() }
    }

    func start(peerConnection: PeerConnection, announcedPads: Set<UInt8>) {
        sendLock.withLock { self.announcedPads = announcedPads }

        condition.withLock {
            self.peerConnection = peerConnection

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

            let peerConnection = isRunning ? self.peerConnection : nil
            let isStillRunning = isRunning

            condition.unlock()

            guard isStillRunning else { return }

            if let peerConnection {
                sendLock.withLock { send(on: peerConnection) }
            }
        }
    }

    private func send(on peerConnection: PeerConnection) {
        let maximumQueuedBytes: UInt64 = 4096

        guard peerConnection.bufferedAmount(on: .input) < maximumQueuedBytes else { return }

        let timestamp = (CACurrentMediaTime() - clockOrigin) * 1000
        let snapshot = inputState.drain(now: timestamp)
        announce(snapshot.addedPads, on: peerConnection)

        withdraw(snapshot.removedPads, on: peerConnection)

        guard let packet = snapshot.report.encoded(sequence: sequenceNumber, timestamp: timestamp)
        else {
            return
        }

        if peerConnection.send(packet, on: .input) {
            sequenceNumber &+= 1
        }
    }

    private func announce(_ addedPads: [UInt8], on peerConnection: PeerConnection) {
        for index in addedPads where !announcedPads.contains(index) {
            peerConnection.send(
                ControlMessage.gamepadChanged(index: Int(index), isAdded: true).json,
                on: .control
            )

            announcedPads.insert(index)
        }
    }

    private func withdraw(_ removedPads: [UInt8], on peerConnection: PeerConnection) {
        for index in removedPads where announcedPads.contains(index) && index != 0 {
            peerConnection.send(
                ControlMessage.gamepadChanged(index: Int(index), isAdded: false).json,
                on: .control
            )

            announcedPads.remove(index)
        }
    }

    func stop() -> Set<UInt8> {
        condition.withLock {
            isRunning = false
            peerConnection = nil

            condition.signal()
        }

        return sendLock.withLock { announcedPads }
    }

    private func signal() {
        condition.withLock {
            isSignalled = true

            condition.signal()
        }
    }
}

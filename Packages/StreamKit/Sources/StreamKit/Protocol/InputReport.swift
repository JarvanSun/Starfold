//
//  InputReport.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct InputReport {
    var frames: [FrameTimingRecord] = []
    var gamepads: [(index: UInt8, state: GamepadState)] = []

    private var maximumRecordsPerSection: Int { 255 }

    func encoded(sequence: UInt32, timestamp: Double) -> Data? {
        guard !presentTypes.isEmpty else { return nil }

        var writer = ByteWriter()
        writer.appendHeader(types: presentTypes, sequence: sequence, timestamp: timestamp)
        appendFrames(to: &writer, timestamp: timestamp)
        appendGamepads(to: &writer)
        return writer.data
    }

    private var presentTypes: [InputReportType] {
        let sections: [(InputReportType, Bool)] = [
            (.metadata, !frames.isEmpty),
            (.gamepad, !gamepads.isEmpty),
        ]
        return sections.filter(\.1).map(\.0)
    }

    private func appendFrames(to writer: inout ByteWriter, timestamp: Double) {
        guard !frames.isEmpty else { return }

        let packetTime = UInt32(truncatingIfNeeded: Int64(timestamp))

        writer.append(UInt8(min(frames.count, maximumRecordsPerSection)))

        for frame in frames.prefix(maximumRecordsPerSection) {
            writer.append(frame.rtpTimestamp)
            writer.append(frame.firstPacketArrival)
            writer.append(frame.submittedToDecoder)
            writer.append(frame.decoded)
            writer.append(frame.rendered)
            writer.append(packetTime)
            writer.append(packetTime)
        }
    }

    private func appendGamepads(to writer: inout ByteWriter) {
        guard !gamepads.isEmpty else { return }

        writer.append(UInt8(min(gamepads.count, maximumRecordsPerSection)))

        for (index, state) in gamepads.prefix(maximumRecordsPerSection) {
            writer.append(index)
            writer.append(state.buttons.rawValue)
            writer.append(axis(state.leftStick.x))
            writer.append(axis(state.leftStick.y))
            writer.append(axis(state.rightStick.x))
            writer.append(axis(state.rightStick.y))
            writer.append(trigger(state.leftTrigger))
            writer.append(trigger(state.rightTrigger))
            writer.append(state.physicality)
            writer.append(UInt32(0))
        }
    }

    private func axis(_ value: Float) -> Int16 {
        guard value.isFinite else { return 0 }

        return Int16((max(-1, min(1, value)) * 32767).rounded(.towardZero))
    }

    private func trigger(_ value: Float) -> UInt16 {
        guard value.isFinite else { return 0 }

        return UInt16((max(0, min(1, value)) * 65535).rounded(.towardZero))
    }

}

private extension GamepadState {
    var physicality: UInt32 {
        let analogFlags: [(UInt32, Bool)] = [
            (0x10000, leftTrigger > 0),
            (0x20000, rightTrigger > 0),
            (0x40000, leftStick.x != 0),
            (0x80000, leftStick.y != 0),
            (0x100000, rightStick.x != 0),
            (0x200000, rightStick.y != 0),
        ]
        let buttonFlags = GamepadButton.allCases
            .filter { buttons.contains($0) }
            .reduce(UInt32(0)) { $0 | $1.physicalityFlag }
        return analogFlags.filter(\.1).reduce(buttonFlags) { $0 | $1.0 }
    }
}

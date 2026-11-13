//
//  ServerInputPacket.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct ServerInputPacket {
    let data: Data

    var events: [ServerInputEvent] {
        var reader = ByteReader(data)
        guard let flags = reader.readUInt16() else { return [] }

        var events: [ServerInputEvent] = []

        if InputReportType.serverMetadata.isPresent(in: flags) {
            guard let videoSize = readVideoSize(from: &reader) else { return events }

            events.append(videoSize)
        }

        if InputReportType.vibration.isPresent(in: flags),
            let vibration = readVibration(from: &reader)
        {
            events.append(vibration)
        }

        return events
    }

    private func readVideoSize(from reader: inout ByteReader) -> ServerInputEvent? {
        guard let height = reader.readUInt32(), let width = reader.readUInt32() else { return nil }

        return .videoSize(width: Int(width), height: Int(height))
    }

    private func readVibration(from reader: inout ByteReader) -> ServerInputEvent? {
        guard reader.readUInt8() != nil,
            let index = reader.readUInt8(),
            let left = reader.readUInt8(),
            let right = reader.readUInt8(),
            let leftTrigger = reader.readUInt8(),
            let rightTrigger = reader.readUInt8(),
            let duration = reader.readUInt16(),
            let delay = reader.readUInt16(),
            let repeatCount = reader.readUInt8()
        else { return nil }

        let effect = VibrationEffect(
            gamepadIndex: index,
            leftMotor: unitIntensity(left),
            rightMotor: unitIntensity(right),
            leftTrigger: unitIntensity(leftTrigger),
            rightTrigger: unitIntensity(rightTrigger),
            duration: .milliseconds(Int(duration)),
            delay: .milliseconds(Int(delay)),
            repeatCount: Int(repeatCount)
        )
        return .vibration(effect)
    }

    private func unitIntensity(_ percent: UInt8) -> Float {
        min(Float(percent), 100) / 100
    }
}

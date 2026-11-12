//
//  VibrationEffect.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct VibrationEffect: Equatable, Sendable {
    public var gamepadIndex: UInt8
    public var leftMotor: Float
    public var rightMotor: Float

    var leftTrigger: Float
    var rightTrigger: Float
    var duration: Duration
    var delay: Duration
    var repeatCount: Int

    init(
        gamepadIndex: UInt8,
        leftMotor: Float,
        rightMotor: Float,
        leftTrigger: Float,
        rightTrigger: Float,
        duration: Duration,
        delay: Duration = .zero,
        repeatCount: Int = 0
    ) {
        self.gamepadIndex = gamepadIndex
        self.leftMotor = leftMotor
        self.rightMotor = rightMotor
        self.leftTrigger = leftTrigger
        self.rightTrigger = rightTrigger
        self.duration = duration
        self.delay = delay
        self.repeatCount = repeatCount
    }
}

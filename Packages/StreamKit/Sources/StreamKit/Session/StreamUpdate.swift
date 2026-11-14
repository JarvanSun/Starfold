//
//  StreamUpdate.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum StreamUpdate: Sendable, Equatable {
    case phase(StreamPhase)
    case statistics(StreamStatistics)
    case dialog(SystemDialogRequest)
    case dialogDismissed(id: String)
    case vibration(VibrationEffect)
    case videoSize(width: Int, height: Int)
    case touchControls(TouchControlsCommand)
    case runningTitle(RunningTitle)
}

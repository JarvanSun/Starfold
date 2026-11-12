//
//  StreamConnection.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

public nonisolated protocol StreamConnection: Sendable {
    var updates: AsyncStream<StreamUpdate> { get }

    func start(sink: VideoFrameReceiving) async
    func stop(reason: StreamEndReason) async
    func setGamepad(_ index: UInt8, state: GamepadState?)
    func pressGuide() async
    func requestKeyframe() async
    func answerDialog(id: String, buttonIndex: Int) async
    func answerKeyboard(id: String, text: String?) async
}

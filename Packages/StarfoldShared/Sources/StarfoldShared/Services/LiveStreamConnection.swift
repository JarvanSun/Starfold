//
//  LiveStreamConnection.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

struct LiveStreamConnection: StreamConnection {
    private let controller: StreamController
    private let runtime: StreamRuntime

    var updates: AsyncStream<StreamUpdate> {
        controller.updates
    }

    init(controller: StreamController, runtime: StreamRuntime) {
        self.controller = controller
        self.runtime = runtime
    }

    func start(sink: VideoFrameReceiving) async {
        await controller.start(sink: sink, runtime: runtime)
    }

    func stop(reason: StreamEndReason) async {
        await controller.stop(reason: reason)
    }

    func setGamepad(_ index: UInt8, state: GamepadState?) {
        controller.setGamepad(index, state: state)
    }

    func pressGuide() async {
        await controller.pressGuide()
    }

    func requestKeyframe() async {
        await controller.requestKeyframe()
    }

    func answerDialog(id: String, buttonIndex: Int) async {
        await controller.answerDialog(id: id, buttonIndex: buttonIndex)
    }

    func answerKeyboard(id: String, text: String?) async {
        await controller.answerKeyboard(id: id, text: text)
    }
}

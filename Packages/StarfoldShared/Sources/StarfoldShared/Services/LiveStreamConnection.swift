//
//  LiveStreamConnection.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

struct LiveStreamConnection: StreamConnection {
    private let streamController: StreamController
    private let streamRuntime: StreamRuntime

    var updates: AsyncStream<StreamUpdate> {
        streamController.updates
    }

    init(streamController: StreamController, streamRuntime: StreamRuntime) {
        self.streamController = streamController
        self.streamRuntime = streamRuntime
    }

    func start(sink: VideoFrameReceiving) async {
        await streamController.start(sink: sink, runtime: streamRuntime)
    }

    func stop(reason: StreamEndReason) async {
        await streamController.stop(reason: reason)
    }

    func setGamepad(_ index: UInt8, state: GamepadState?) {
        streamController.setGamepad(index, state: state)
    }

    func pressGuide() async {
        await streamController.pressGuide()
    }

    func requestKeyframe() async {
        await streamController.requestKeyframe()
    }

    func answerDialog(id: String, buttonIndex: Int) async {
        await streamController.answerDialog(id: id, buttonIndex: buttonIndex)
    }

    func answerKeyboard(id: String, text: String?) async {
        await streamController.answerKeyboard(id: id, text: text)
    }

    func announceTouchBundle(version: String, versionName: String) async {
        await streamController.announceTouchBundle(version: version, versionName: versionName)
    }
}

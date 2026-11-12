//
//  PreviewStreamConnection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit

nonisolated struct PreviewStreamConnection: StreamConnection {
    let updates: AsyncStream<StreamUpdate>

    init(updates: [StreamUpdate]) {
        self.updates = AsyncStream { continuation in
            for update in updates {
                continuation.yield(update)
            }
        }
    }

    func start(sink: VideoFrameReceiving) async {}

    func stop(reason: StreamEndReason) async {}

    func setGamepad(_ index: UInt8, state: GamepadState?) {}

    func pressGuide() async {}

    func requestKeyframe() async {}

    func answerDialog(id: String, buttonIndex: Int) async {}

    func answerKeyboard(id: String, text: String?) async {}
}

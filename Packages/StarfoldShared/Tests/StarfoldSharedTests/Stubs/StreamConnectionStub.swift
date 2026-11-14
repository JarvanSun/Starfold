//
//  StreamConnectionStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import Synchronization

@testable import StarfoldShared

struct StreamConnectionStub: StreamConnection {
    final class Requests: Sendable {
        let stopReasons = Mutex<[StreamEndReason]>([])
        let keyframeCount = Mutex(0)
    }

    let updates: AsyncStream<StreamUpdate>

    private let continuation: AsyncStream<StreamUpdate>.Continuation
    private let requests = Requests()

    var stopReasons: [StreamEndReason] {
        requests.stopReasons.withLock { $0 }
    }

    var keyframeRequestCount: Int {
        requests.keyframeCount.withLock { $0 }
    }

    init(updates: [StreamUpdate]) {
        (self.updates, continuation) = AsyncStream.makeStream()

        for update in updates {
            continuation.yield(update)
        }
    }

    func send(_ update: StreamUpdate) {
        continuation.yield(update)
    }

    func start(sink: VideoFrameReceiving) async {}

    func stop(reason: StreamEndReason) async {
        requests.stopReasons.withLock { $0.append(reason) }
    }

    func setGamepad(_ index: UInt8, state: GamepadState?) {}

    func pressGuide() async {}

    func requestKeyframe() async {
        requests.keyframeCount.withLock { $0 += 1 }
    }

    func answerDialog(id: String, buttonIndex: Int) async {}

    func answerKeyboard(id: String, text: String?) async {}

    func announceTouchBundle(version: String, versionName: String) async {}
}

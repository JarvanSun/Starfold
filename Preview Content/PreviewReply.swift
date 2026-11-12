//
//  PreviewReply.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StarfoldShared

struct PreviewReply {
    let state: LoadState

    func answer<Value>(_ value: Value) async throws -> Value {
        switch state {
        case .loaded: return value
        case .failed(let message): throw PreviewError(message: message)
        case .idle, .loading: return try await neverAnswer()
        }
    }

    func neverAnswer<Value>() async throws -> Value {
        try await Task.sleep(for: unansweredDuration)

        throw CancellationError()
    }
}

private extension PreviewReply {
    var unansweredDuration: Duration {
        .seconds(86_400)
    }
}

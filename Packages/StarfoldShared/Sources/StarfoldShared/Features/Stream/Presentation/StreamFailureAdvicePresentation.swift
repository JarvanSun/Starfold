//
//  StreamFailureAdvicePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension StreamFailureAdvice {
    public var text: LocalizedStringResource {
        switch self {
        case .consoleOffline: .init("stream.advice.consoleOffline", bundle: .module)
        case .remotePlayOff: .init("stream.advice.remotePlayOff", bundle: .module)
        case .consoleStillClosingLastStream:
            .init("stream.advice.consoleStillClosingLastStream", bundle: .module)
        case .consoleNotAnswering: .init("stream.advice.consoleNotAnswering", bundle: .module)
        case .gameStillStarting: .init("stream.advice.gameStillStarting", bundle: .module)
        case .needsGamePass: .init("stream.advice.needsGamePass", bundle: .module)
        case .networkDropped: .init("stream.advice.networkDropped", bundle: .module)
        case .unrecognized(let message):
            .init("stream.advice.unrecognized \(message)", bundle: .module)
        }
    }
}

//
//  StreamStatusPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension StreamStatus {
    public var title: LocalizedStringResource {
        switch self {
        case .connecting: .init("stream.status.connecting", bundle: .module)
        case .queued(let wait?): .init("stream.status.queued \(wait)", bundle: .module)
        case .queued(nil): .init("stream.status.waitingInLine", bundle: .module)
        case .ended(let reason, _): reason.title
        }
    }
}

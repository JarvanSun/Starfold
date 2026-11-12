//
//  StreamStatus.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

public enum StreamStatus: Equatable {
    case connecting
    case queued(estimatedWait: String?)
    case ended(StreamEndReason, advice: StreamFailureAdvice?)
}

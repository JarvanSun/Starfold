//
//  RemoteICECandidate.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct RemoteICECandidate: Equatable, Sendable {
    public var candidate: String
    public var sdpMid: String
    public var sdpMLineIndex: Int

    public init(candidate: String, sdpMid: String, sdpMLineIndex: Int) {
        self.candidate = candidate
        self.sdpMid = sdpMid
        self.sdpMLineIndex = sdpMLineIndex
    }
}

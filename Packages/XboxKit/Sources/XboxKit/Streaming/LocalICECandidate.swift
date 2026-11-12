//
//  LocalICECandidate.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct LocalICECandidate: Equatable, Sendable {
    public var candidate: String
    public var sdpMid: String?
    public var sdpMLineIndex: Int32

    public init(candidate: String, sdpMid: String?, sdpMLineIndex: Int32) {
        self.candidate = candidate
        self.sdpMid = sdpMid
        self.sdpMLineIndex = sdpMLineIndex
    }
}

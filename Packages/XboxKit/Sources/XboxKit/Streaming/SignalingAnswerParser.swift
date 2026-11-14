//
//  SignalingAnswerParser.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct SignalingAnswerParser: Sendable {
    func sdpAnswer(from body: Data) throws -> (sdp: String, versions: ChannelVersions)? {
        guard let answer = try exchangeResponse(in: body) as? [String: Any] else {
            return nil
        }

        if let failedStatus = failedStatus(in: answer) {
            throw GSSVSessionError.failed(
                code: failedStatus,
                message: answer["errorDetails"] as? String
            )
        }

        guard let sdp = answer["sdp"] as? String else {
            throw GSSVSessionError.malformedResponse("SDP answer without sdp")
        }

        let versions = ChannelVersions(
            chat: negotiatedVersion("chat", in: answer),
            control: negotiatedVersion("control", in: answer),
            input: negotiatedVersion("input", in: answer),
            message: negotiatedVersion("message", in: answer)
        )
        return (sdp, versions)
    }

    private func exchangeResponse(in body: Data) throws -> Any? {
        guard let outer = try JSONSerialization.jsonObject(with: body) as? [String: Any] else {
            return nil
        }

        if let hostError = hostError(in: outer) {
            throw hostError
        }

        switch outer["exchangeResponse"] {
        case let text as String: return try? JSONSerialization.jsonObject(with: Data(text.utf8))
        case let decoded?: return decoded
        case nil: return nil
        }
    }

    private func hostError(in outer: [String: Any]) -> GSSVSessionError? {
        guard
            let details = outer["errorDetails"] as? [String: Any],
            let code = details["code"] as? String
        else {
            return nil
        }

        return .failed(code: code, message: details["message"] as? String)
    }

    private func failedStatus(in answer: [String: Any]) -> String? {
        guard let status = answer["status"] as? String, status != "success" else {
            return nil
        }

        return status
    }

    private func negotiatedVersion(_ channel: String, in answer: [String: Any]) -> Int {
        let defaultChannelVersion = 1

        return (answer[channel] as? NSNumber)?.intValue ?? defaultChannelVersion
    }

    func iceCandidates(from body: Data) throws -> [RemoteICECandidate]? {
        guard let entries = try exchangeResponse(in: body) as? [[String: Any]] else {
            return nil
        }

        return entries.flatMap(remoteCandidates)
    }

    private func remoteCandidates(in entry: [String: Any]) -> [RemoteICECandidate] {
        guard let line = entry["candidate"] as? String else {
            return []
        }

        let mid = entry["sdpMid"] as? String ?? "0"
        let index =
            (entry["sdpMLineIndex"] as? NSNumber)?.intValue
            ?? Int(entry["sdpMLineIndex"] as? String ?? "") ?? 0
        return HostICECandidate(line).expanded.map { candidate in
            RemoteICECandidate(candidate: candidate, sdpMid: mid, sdpMLineIndex: index)
        }
    }
}

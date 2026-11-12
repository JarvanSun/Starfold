//
//  SignalingAnswerParserTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct SignalingAnswerParserTests {
    @Test
    func sdpAnswerThenReadsDoublyEncodedResponseWithChannelVersions() throws {
        // Given
        let answer =
            #"{"chat":1,"control":3,"input":8,"message":1,"messageType":"answer","sdp":"v=0\r\na=mid:2\r\n","sdpType":"answer","status":"success"}"#
        let body = try JSONSerialization.data(
            withJSONObject: [
                "exchangeResponse": answer,
                "errorDetails": ["code": NSNull(), "message": NSNull()],
            ]
        )

        // When
        let parsed = try #require(try SignalingAnswerParser().sdpAnswer(from: body))

        // Then
        #expect(parsed.sdp == "v=0\r\na=mid:2\r\n")
        #expect(parsed.versions == ChannelVersions(chat: 1, control: 3, input: 8, message: 1))
    }

    @Test
    func sdpAnswerWhenExchangeResponseIsMissingThenIsNil() throws {
        // Given
        let body = Data(#"{"errorDetails":{"code":null}}"#.utf8)

        // When / Then
        #expect(try SignalingAnswerParser().sdpAnswer(from: body) == nil)
    }

    @Test
    func sdpAnswerWhenHostSendsErrorCodeThenThrowsFailed() {
        // Given
        let body = Data(#"{"errorDetails":{"code":"SessionNotFound","message":"gone"}}"#.utf8)

        // When / Then
        #expect(throws: GSSVSessionError.failed(code: "SessionNotFound", message: "gone")) {
            _ = try SignalingAnswerParser().sdpAnswer(from: body)
        }
    }

    @Test
    func iceCandidatesThenParseStringLineIndexAndExpandTeredo() throws {
        // Given
        let answer = """
            [{"candidate":"a=candidate:1 1 UDP 100 2001:0:4136:e378:8000:2bce:34ff:8efa 9002 typ host ","messageType":"iceCandidate","sdpMLineIndex":"0","sdpMid":"0"},
             {"candidate":"a=end-of-candidates","messageType":"iceCandidate","sdpMLineIndex":"0","sdpMid":"0"}]
            """
        let body = try JSONSerialization.data(withJSONObject: ["exchangeResponse": answer])

        // When
        let candidates = try #require(try SignalingAnswerParser().iceCandidates(from: body))

        // Then
        #expect(candidates.count == 3)
        #expect(candidates.allSatisfy { $0.sdpMid == "0" && $0.sdpMLineIndex == 0 })
    }
}

//
//  StreamFailureAdviceTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import Testing

@testable import StarfoldShared

@MainActor
struct StreamFailureAdviceTests {
    @Test(arguments: [
        ("WNSError: WaitingForServerToRegister", StreamFailureAdvice.consoleOffline),
        ("The user has disabled streaming on this console", .remotePlayOff),
        (
            "CommandProxyError: xHome : NotFound : NotFound : State ServerStartStreamingV2CommandSent",
            .consoleStillClosingLastStream
        ),
        ("Timed out waiting for state", .consoleNotAnswering),
        (
            #"HTTP 409 from weu.core.gssv-play-prod.xboxlive.com: {"code":"DuplicateSessionRequest","statusCode":409}"#,
            .gameStillStarting
        ),
        ("HTTP 400", .needsGamePass),
        ("SomethingNew", .unrecognized("SomethingNew")),
    ])
    func initWhenHostSendsMessageThenPicksMatchingAdvice(
        message: String,
        expected: StreamFailureAdvice
    ) {
        #expect(StreamFailureAdvice(hostMessage: message) == expected)
    }

    @Test
    func initFromEndReasonWhenFailedThenReadsTheHostMessage() {
        #expect(
            StreamFailureAdvice(endReason: .failed("WaitingForServerToRegister")) == .consoleOffline
        )
    }

    @Test
    func initFromEndReasonWhenTheConnectionWasLostThenAdvisesCheckingTheNetwork() {
        #expect(StreamFailureAdvice(endReason: .connectionLost) == .networkDropped)
    }

    @Test
    func initFromEndReasonWhenTheStreamSimplyEndedThenHasNoAdvice() {
        #expect(StreamFailureAdvice(endReason: .userStopped) == nil)
        #expect(StreamFailureAdvice(endReason: .hostEnded) == nil)
    }
}

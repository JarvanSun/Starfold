//
//  SessionStateTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import XboxKit

struct SessionStateTests {
    @Test(
        arguments: [
            ("Provisioning", SessionState.provisioning),
            ("WaitingForResources", .waitingForResources),
            ("ReadyToConnect", .readyToConnect),
            ("Provisioned", .provisioned),
            ("Paused", .other("Paused")),
        ]
    )
    func initThenMapsHostState(state: String, expected: SessionState) {
        #expect(SessionState(fields: ["state": state]) == expected)
    }

    @Test
    func initWhenFailedThenCarriesHostCodeAndMessage() {
        // Given
        let fields: [String: Any] = [
            "state": "Failed",
            "errorDetails": ["code": "WNSError", "message": "WaitingForServerToRegister"],
        ]

        // When / Then
        #expect(
            SessionState(fields: fields)
                == .failed(code: "WNSError", message: "WaitingForServerToRegister")
        )
    }
}

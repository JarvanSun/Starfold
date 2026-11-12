//
//  StreamEndReasonTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing
import XboxKit

@testable import StreamKit

struct StreamEndReasonTests {
    @Test(
        arguments: [
            (XboxHTTPError.dummyDuplicateSession, "HTTP 409 DuplicateSessionRequest"),
            (.dummyBadRequest, "HTTP 400"),
        ]
    )
    func initWhenHTTPFailureThenKeepsTheHostsCode(error: XboxHTTPError, expected: String) {
        #expect(StreamEndReason(failure: error) == .failed(expected))
    }
}

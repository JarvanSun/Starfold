//
//  XboxHTTPErrorTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct XboxHTTPErrorTests {
    @Test(
        arguments: [
            (
                #" {"XErr":2148916233} "#,
                #"user.auth.xboxlive.com returned 401: {"XErr":2148916233}"#
            ),
            ("", "user.auth.xboxlive.com returned 401"),
        ]
    )
    func errorDescriptionThenNamesHostStatusAndTrimmedBody(body: String, expected: String) {
        // Given
        let error = XboxHTTPError(
            url: URL(string: "https://user.auth.xboxlive.com/user/authenticate")!,
            statusCode: 401,
            body: body,
            headers: [:]
        )

        // When / Then
        #expect(error.errorDescription == expected)
    }
}

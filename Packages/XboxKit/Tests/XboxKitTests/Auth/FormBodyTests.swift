//
//  FormBodyTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import XboxKit

struct FormBodyTests {
    @Test
    func encodedThenPercentEncodesSpacesColonsSlashesAndPlus() {
        // Given
        let form = FormBody([("scope", "service::http://Passport.NET/purpose::X"), ("a b", "c+d")])

        // When
        let encoded = String(decoding: form.encoded, as: UTF8.self)

        // Then
        #expect(
            encoded == "scope=service%3A%3Ahttp%3A%2F%2FPassport.NET%2Fpurpose%3A%3AX&a%20b=c%2Bd"
        )
    }

    @Test
    func headersThenDeclareFormURLEncodedContent() {
        #expect(FormBody([]).headers == ["Content-Type": "application/x-www-form-urlencoded"])
    }
}

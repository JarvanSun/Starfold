//
//  SignInCodeTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing
import XboxKit

@testable import StarfoldShared

struct SignInCodeTests {
    @Test
    func charactersThenAreTheCodeOneByOneInOrder() {
        // Given
        let code = SignInCode(prompt: .dummy(userCode: "AB7"))

        // Then
        #expect(code.characters.map(\.text) == ["A", "B", "7"])
        #expect(code.characters.map(\.id) == [0, 1, 2])
    }

    @Test
    func spelledOutThenSeparatesTheCharactersForVoiceOver() {
        // Given
        let code = SignInCode(prompt: .dummy(userCode: "AB7"))

        // Then
        #expect(code.spelledOut == "A B 7")
    }

    @Test
    func addressThenIsTheSignInPageWithoutSchemeOrWWW() {
        // Given
        let code = SignInCode(prompt: .dummy(userCode: "AB7"))

        // Then
        #expect(code.address == "microsoft.com/link")
    }

    @Test
    func pageThenCarriesTheCodeForTheBrowserAndTheQRCode() {
        // Given
        let code = SignInCode(prompt: .dummy(userCode: "AB7"))

        // Then
        #expect(code.page == URL(string: "https://www.microsoft.com/link?otc=AB7"))
        #expect(code.qrCode == QRCode(url: code.page))
    }
}

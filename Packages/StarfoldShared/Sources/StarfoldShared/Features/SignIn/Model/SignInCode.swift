//
//  SignInCode.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

public struct SignInCode: Equatable {
    public let text: String
    public let address: String
    public let page: URL
    public let qrCode: QRCode

    public var characters: [SignInCodeCharacter] {
        text.enumerated().map { .init(id: $0.offset, text: String($0.element)) }
    }

    public var spelledOut: String {
        text.map(String.init).joined(separator: " ")
    }

    public init(prompt: DeviceCodePrompt) {
        text = prompt.userCode
        address = prompt.verificationURL.addressWithoutScheme
        page = prompt.verificationURLComplete
        qrCode = QRCode(url: prompt.verificationURLComplete)
    }
}

private extension URL {
    var addressWithoutScheme: String {
        let host = (host() ?? "").replacingOccurrences(of: "www.", with: "")
        return host + path()
    }
}

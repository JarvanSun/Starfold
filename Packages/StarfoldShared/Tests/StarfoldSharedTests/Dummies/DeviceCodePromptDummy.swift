//
//  DeviceCodePromptDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension DeviceCodePrompt {
    static func dummy(userCode: String) -> DeviceCodePrompt {
        .init(
            userCode: userCode,
            verificationURL: URL(string: "https://www.microsoft.com/link")!,
            verificationURLComplete: URL(string: "https://www.microsoft.com/link?otc=\(userCode)")!,
            expiresAt: .now + 900,
            deviceCode: "device-\(userCode)",
            pollInterval: .seconds(1)
        )
    }
}

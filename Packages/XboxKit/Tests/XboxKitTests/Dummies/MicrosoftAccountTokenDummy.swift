//
//  MicrosoftAccountTokenDummy.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

@testable import XboxKit

extension MicrosoftAccountToken {
    static var dummyExpiringInAnHour: MicrosoftAccountToken {
        .init(
            accessToken: "msa-access",
            refreshToken: "msa-refresh",
            expiresAt: .init(timeIntervalSince1970: 1_800_003_600),
            userID: nil
        )
    }
}

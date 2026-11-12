//
//  MicrosoftIdentity.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct MicrosoftIdentity: Sendable {
    let clientID: String

    var scope: String {
        "xboxlive.signin openid profile offline_access"
    }

    var deviceCodeConfiguration: DeviceCodeFlow.Configuration {
        .init(
            deviceCodeURL: URL(
                string: "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode"
            )!,
            tokenURL: URL(string: "https://login.microsoftonline.com/consumers/oauth2/v2.0/token")!,
            clientID: clientID,
            scope: scope
        )
    }
}

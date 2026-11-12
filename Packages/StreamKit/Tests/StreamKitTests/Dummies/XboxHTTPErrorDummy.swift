//
//  XboxHTTPErrorDummy.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension XboxHTTPError {
    static var dummyDuplicateSession: XboxHTTPError {
        .init(
            url: URL(
                string: "https://weu.core.gssv-play-prod.xboxlive.com/v5/sessions/cloud/play"
            )!,
            statusCode: 409,
            body:
                #"{"code":"DuplicateSessionRequest","statusCode":409,"message":"Rejecting duplicate"}"#,
            headers: [:]
        )
    }

    static var dummyBadRequest: XboxHTTPError {
        .init(url: URL(string: "https://example.com")!, statusCode: 400, body: "", headers: [:])
    }
}

//
//  DeviceCodeFlowTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct DeviceCodeFlowTests {
    @Test
    func startWhenServerSendsNoCompleteURLThenVerificationURLCarriesCode() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.deviceCode, json: .dummyDeviceCodeResponse())
        let flow = makeFlow(server: server)

        // When
        let prompt = try await flow.start()

        // Then
        #expect(
            prompt.verificationURLComplete.absoluteString
                == "https://www.microsoft.com/link?otc=ABCD1234"
        )
    }
}

private extension DeviceCodeFlowTests {
    func makeFlow(server: XboxServerStub) -> DeviceCodeFlow {
        .init(
            configuration: MicrosoftIdentity(clientID: .dummyClientID).deviceCodeConfiguration,
            http: server.client
        )
    }
}

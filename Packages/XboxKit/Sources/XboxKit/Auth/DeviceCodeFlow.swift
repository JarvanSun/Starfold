//
//  DeviceCodeFlow.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

struct DeviceCodeFlow: Sendable {
    struct Configuration: Sendable {
        var deviceCodeURL: URL
        var tokenURL: URL
        var clientID: String
        var scope: String
    }

    private let configuration: Configuration
    private let http: HTTPClient
    private let now: @Sendable () -> Date

    init(
        configuration: Configuration,
        http: HTTPClient,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.configuration = configuration
        self.http = http
        self.now = now
    }

    func start() async throws -> DeviceCodePrompt {
        let form = FormBody([
            ("client_id", configuration.clientID),
            ("scope", configuration.scope),
            ("response_type", "device_code"),
        ])
        let response = try await http.decodedBody(
            DeviceCodeResponse.self,
            for: request(to: configuration.deviceCodeURL, form: form)
        )
        guard let verificationURL = URL(string: response.verificationURI) else {
            throw URLError(.badServerResponse)
        }

        let defaultPollSeconds = 5

        return .init(
            userCode: response.userCode,
            verificationURL: verificationURL,
            verificationURLComplete: response.verificationURIComplete.flatMap(URL.init(string:))
                ?? prefilledVerificationURL(verificationURL, code: response.userCode),
            expiresAt: now().addingTimeInterval(TimeInterval(response.expiresIn)),
            deviceCode: response.deviceCode,
            pollInterval: .seconds(response.interval ?? defaultPollSeconds)
        )
    }

    private func prefilledVerificationURL(_ url: URL, code: String) -> URL {
        url.appending(queryItems: [URLQueryItem(name: "otc", value: code)])
    }

    func waitForToken(_ prompt: DeviceCodePrompt) async throws -> MicrosoftAccountToken {
        var interval = prompt.pollInterval

        let slowDownIncrement: Duration = .seconds(5)

        while now() < prompt.expiresAt {
            try await Task.sleep(for: interval)

            let response = try await pollToken(deviceCode: prompt.deviceCode)

            switch (response.accessToken, response.error) {
            case (let accessToken?, _): return signedInToken(accessToken, from: response)
            case (nil, "authorization_pending"): continue
            case (nil, "slow_down"): interval += slowDownIncrement
            case (nil, "expired_token"): throw DeviceCodeError.expired
            case (nil, "authorization_declined"), (nil, "access_denied"):
                throw DeviceCodeError.declined
            case (nil, _): throw serverError(from: response)
            }
        }

        throw DeviceCodeError.expired
    }

    private func pollToken(deviceCode: String) async throws -> TokenResponse {
        let form = FormBody([
            ("client_id", configuration.clientID),
            ("grant_type", "urn:ietf:params:oauth:grant-type:device_code"),
            ("device_code", deviceCode),
        ])
        let response = try await http.send(request(to: configuration.tokenURL, form: form))
        return try JSONDecoder().decode(TokenResponse.self, from: response.body)
    }

    private func request(to url: URL, form: FormBody) -> HTTPClient.Request {
        .init(url: url, method: "POST", headers: form.headers, body: form.encoded)
    }

    private func signedInToken(_ accessToken: String, from reply: TokenResponse)
        -> MicrosoftAccountToken
    {
        .init(
            accessToken: accessToken,
            refreshToken: reply.refreshToken,
            expiresAt: expiry(of: reply),
            userID: reply.userID
        )
    }

    private func expiry(of response: TokenResponse) -> Date {
        let defaultTokenLifetime = 3600

        return now().addingTimeInterval(TimeInterval(response.expiresIn ?? defaultTokenLifetime))
    }

    func refresh(_ token: MicrosoftAccountToken) async throws -> MicrosoftAccountToken {
        guard let refreshToken = token.refreshToken else {
            throw DeviceCodeError.expired
        }

        let form = FormBody([
            ("client_id", configuration.clientID),
            ("grant_type", "refresh_token"),
            ("refresh_token", refreshToken),
            ("scope", configuration.scope),
        ])
        let response = try await http.decodedBody(
            TokenResponse.self,
            for: request(to: configuration.tokenURL, form: form)
        )
        guard let accessToken = response.accessToken else {
            throw serverError(from: response)
        }

        return .init(
            accessToken: accessToken,
            refreshToken: response.refreshToken ?? refreshToken,
            expiresAt: expiry(of: response),
            userID: response.userID ?? token.userID
        )
    }

    private func serverError(from response: TokenResponse) -> DeviceCodeError {
        .server(code: response.error ?? "unknown", description: response.errorDescription ?? "")
    }
}

// MARK: - Private

private extension DeviceCodeFlow {
    struct DeviceCodeResponse: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case deviceCode = "device_code"
            case userCode = "user_code"
            case verificationURI = "verification_uri"
            case verificationURIComplete = "verification_uri_complete"
            case expiresIn = "expires_in"
            case interval
        }

        let deviceCode: String
        let userCode: String
        let verificationURI: String
        let verificationURIComplete: String?
        let expiresIn: Int
        let interval: Int?
    }

    struct TokenResponse: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case expiresIn = "expires_in"
            case userID = "user_id"
            case error
            case errorDescription = "error_description"
        }

        let accessToken: String?
        let refreshToken: String?
        let expiresIn: Int?
        let userID: String?
        let error: String?
        let errorDescription: String?
    }
}

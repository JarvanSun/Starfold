//
//  XboxServerStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Synchronization
import XboxKit

final class XboxServerStub: Sendable {
    private struct State {
        var routes: [String: [HTTPClient.Response]] = [:]
        var hangingRoutes: Set<String> = []
        var requests: [HTTPClient.Request] = []
    }

    private let state = Mutex(State())

    var httpClient: HTTPClient {
        HTTPClient { [self] request in
            try await respond(to: request)
        }
    }

    func on(_ endpoint: XboxEndpoint, status: Int = 200, json: String) {
        state.withLock { state in
            state.routes[endpoint.rawValue, default: []]
                .append(.init(statusCode: status, body: Data(json.utf8)))
        }
    }

    func hang(_ endpoint: XboxEndpoint) {
        state.withLock { _ = $0.hangingRoutes.insert(endpoint.rawValue) }
    }

    func requestCount(to endpoint: XboxEndpoint) -> Int {
        state.withLock { state in
            state.requests.filter { routeKey(for: $0.url) == endpoint.rawValue }.count
        }
    }
}

extension XboxServerStub {
    func installTokenChain(cloud: CloudEntitlement = .gamePass) {
        on(.userAuthentication, json: .dummyXboxTokenResponse(token: "user"))
        on(
            .securityTokenAuthorization,
            json: .dummyXboxTokenResponse(token: "xsts", gamertag: "NovaPilot", xuid: "2535")
        )
        on(.homeLogin, json: .dummyStreamingLoginResponse(region: .homeRegion))
        installCloudLogin(cloud)
        on(.profile, json: .dummyProfileResponse)
    }

    func installConsoles(_ json: String) {
        on(.homeConsoles, json: json)
    }

    func installSignIn(cloud: CloudEntitlement = .gamePass) {
        installTokenChain(cloud: cloud)
        on(
            .deviceCode,
            json: .dummyDeviceCodeResponse(userCode: "ABCD1234", expiresIn: 900, interval: 0)
        )
        on(.token, json: .dummyMicrosoftTokenResponse)
    }

    func signedInAccount(cloud: CloudEntitlement = .gamePass) async throws -> XboxAccount {
        installSignIn(cloud: cloud)

        let store = AccountStore(
            microsoftClientID: .dummyClientID,
            secretStore: InMemorySecretStore(),
            httpClient: httpClient
        )
        return try await store.completeSignIn(try await store.beginSignIn())
    }

    func installCloudLibrary() {
        on(.cloudTitles, json: .dummyCloudTitles)
        on(.recentCloudTitles, json: .dummyRecentCloudTitles)
        on(.catalogProducts, json: .dummyCatalogProducts)
        on(.curatedList, json: .dummyCuratedList)
    }
}

private extension XboxServerStub {
    var hangDuration: Duration {
        .seconds(3600)
    }

    func installCloudLogin(_ cloud: CloudEntitlement) {
        let denied = #"{"code":"OfferingAccessDenied"}"#

        switch cloud {
        case .gamePass:
            on(.cloudLogin, json: .dummyStreamingLoginResponse(region: .cloudRegion))
        case .freeToPlay:
            on(.cloudLogin, status: 403, json: denied)
            on(.freeToPlayCloudLogin, json: .dummyStreamingLoginResponse(region: .cloudRegion))
        case .unavailable:
            on(.cloudLogin, status: 403, json: denied)
            on(.freeToPlayCloudLogin, status: 403, json: denied)
        }
    }

    func respond(to request: HTTPClient.Request) async throws -> HTTPClient.Response {
        let key = routeKey(for: request.url)

        switch reply(to: request, key: key) {
        case .response(let response): return response
        case .hang:
            try await Task.sleep(for: hangDuration)
            throw unknownRouteError(key)
        case .unknownRoute: throw unknownRouteError(key)
        }
    }

    func reply(to request: HTTPClient.Request, key: String) -> Reply {
        state.withLock { state in
            state.requests.append(request)

            guard !state.hangingRoutes.contains(key) else { return .hang }
            guard var queue = state.routes[key], let first = queue.first else {
                return .unknownRoute
            }

            if queue.count > 1 {
                queue.removeFirst()
                state.routes[key] = queue
            }

            return .response(first)
        }
    }

    func unknownRouteError(_ key: String) -> URLError {
        .init(.unsupportedURL, userInfo: [NSLocalizedDescriptionKey: "No route for \(key)"])
    }

    func routeKey(for url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = nil
        return components.string!
    }
}

private enum Reply {
    case response(HTTPClient.Response)
    case hang
    case unknownRoute
}

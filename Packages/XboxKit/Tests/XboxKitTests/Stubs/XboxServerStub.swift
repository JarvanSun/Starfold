//
//  XboxServerStub.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Synchronization

@testable import XboxKit

final class XboxServerStub: Sendable {
    private struct State {
        var routes: [String: [Result<HTTPClient.Response, URLError>]] = [:]
        var requests: [HTTPClient.Request] = []
    }

    private let state = Mutex(State())

    var requests: [HTTPClient.Request] {
        state.withLock { $0.requests }
    }

    var client: HTTPClient {
        HTTPClient { [self] request in
            try respond(to: request)
        }
    }

    func on(_ url: String, status: Int = 200, json: String) {
        on(url, status: status, body: Data(json.utf8))
    }

    func on(_ url: String, status: Int = 200, body: Data) {
        state.withLock { state in
            state.routes[url, default: []].append(.success(.init(statusCode: status, body: body)))
        }
    }

    func on(_ endpoint: XboxEndpoint, status: Int = 200, json: String) {
        on(endpoint.rawValue, status: status, json: json)
    }

    func fail(_ endpoint: XboxEndpoint, with code: URLError.Code) {
        state.withLock { state in
            state.routes[endpoint.rawValue, default: []].append(.failure(URLError(code)))
        }
    }

    func requests(to url: String) -> [HTTPClient.Request] {
        state.withLock { state in
            state.requests.filter { routeKey(for: $0.url) == url }
        }
    }

    func requests(to endpoint: XboxEndpoint) -> [HTTPClient.Request] {
        requests(to: endpoint.rawValue)
    }
}

private extension XboxServerStub {
    func respond(to request: HTTPClient.Request) throws -> HTTPClient.Response {
        let key = routeKey(for: request.url)
        return try state.withLock { state in
            state.requests.append(request)

            guard var queue = state.routes[key], let first = queue.first else {
                throw URLError(
                    .unsupportedURL,
                    userInfo: [NSURLErrorFailingURLErrorKey: request.url]
                )
            }

            if queue.count > 1 {
                queue.removeFirst()
                state.routes[key] = queue
            }

            return try first.get()
        }
    }

    func routeKey(for url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = nil
        return components.string!
    }
}

//
//  HTTPClient.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

public actor HTTPClient {
    public struct Request: Sendable {
        public var url: URL

        var method: String
        var headers: [String: String]
        var body: Data?
        var timeout: Duration?

        init(
            url: URL,
            method: String = "GET",
            headers: [String: String] = [:],
            body: Data? = nil,
            timeout: Duration? = nil
        ) {
            self.url = url
            self.method = method
            self.headers = headers
            self.body = body
            self.timeout = timeout
        }
    }

    public struct Response: Sendable {
        let statusCode: Int
        let headers: [String: String]
        let body: Data

        public init(statusCode: Int, headers: [String: String] = [:], body: Data) {
            self.statusCode = statusCode
            self.headers = headers
            self.body = body
        }
    }

    public typealias Transport = @Sendable (Request) async throws -> Response

    private let transport: Transport

    public init(session: URLSession = .shared) {
        let urlSessionTransport = URLSessionTransport(session: session)
        self.transport = { request in try await urlSessionTransport.exchange(request) }
    }

    public init(transport: @escaping Transport) {
        self.transport = transport
    }

    func send(_ request: Request) async throws -> Response {
        try await transport(request)
    }

    func successfulBody(for request: Request) async throws -> Data {
        let response = try await send(request)
        guard (200..<300).contains(response.statusCode) else {
            throw XboxHTTPError(
                url: request.url,
                statusCode: response.statusCode,
                body: String(decoding: response.body, as: UTF8.self),
                headers: response.headers
            )
        }

        return response.body
    }

    func decodedBody<Body: Decodable & Sendable>(
        _ type: Body.Type,
        for request: Request
    ) async throws -> Body {
        let body = try await successfulBody(for: request)
        return try JSONDecoder(dateParser: .init()).decode(Body.self, from: body)
    }
}

private struct URLSessionTransport: Sendable {
    let session: URLSession

    func exchange(_ request: HTTPClient.Request) async throws -> HTTPClient.Response {
        let (body, response) = try await session.data(for: urlRequest(for: request))
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        return .init(
            statusCode: httpResponse.statusCode,
            headers: lowercasedHeaders(of: httpResponse),
            body: body
        )
    }

    private func urlRequest(for request: HTTPClient.Request) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body

        if let timeout = request.timeout {
            urlRequest.timeoutInterval = timeInterval(of: timeout)
        }

        for (name, headerValue) in request.headers {
            urlRequest.setValue(headerValue, forHTTPHeaderField: name)
        }

        return urlRequest
    }

    private func timeInterval(of duration: Duration) -> TimeInterval {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
    }

    private func lowercasedHeaders(of response: HTTPURLResponse) -> [String: String] {
        var headers: [String: String] = [:]

        for case (let name as String, let headerValue as String) in response.allHeaderFields {
            headers[name.lowercased()] = headerValue
        }

        return headers
    }
}

//
//  GSSVClientTouchBundles.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension GSSVClient {
    public func inputConfigurations(
        xboxTitleIDs: [String]
    ) async throws -> [TitleInputConfiguration] {
        let request = InputConfigurationsRequest(titleIDs: xboxTitleIDs, titleIDType: "xboxTitleId")
        let response = try await send(
            to: baseURL.appending(path: "v2/titles/inputconfigs"),
            method: "POST",
            body: try JSONEncoder().encode(request)
        )
        return try JSONDecoder().decode([TitleInputConfiguration].self, from: response.body)
    }

    public func touchBundleArchive(id: String) async throws -> Data {
        let downloadURL = try await touchBundleDownloadURL(id: id)
        return try await httpClient.successfulBody(for: .init(url: downloadURL))
    }

    private func touchBundleDownloadURL(id: String) async throws -> URL {
        let url = baseURL.appending(path: "v1/sessions/tabs/\(id)/download")
            .appending(queryItems: [URLQueryItem(name: "noRedirect", value: "true")])
        let response = try await send(to: url, extraHeaders: ["Accept": "*/*"])
        let text = String(decoding: response.body, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let downloadURL = URL(string: text)
        guard let downloadURL, downloadURL.scheme == "https" else {
            throw GSSVSessionError.malformedResponse("touch bundle URL \(text.prefix(200))")
        }

        return downloadURL
    }
}

// MARK: - Private

private extension GSSVClient {
    struct InputConfigurationsRequest: Encodable {
        enum CodingKeys: String, CodingKey {
            case titleIDs = "titleIds"
            case titleIDType = "titleIdType"
        }

        let titleIDs: [String]
        let titleIDType: String
    }
}

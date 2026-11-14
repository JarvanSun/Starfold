//
//  TitleInputConfiguration.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TitleInputConfiguration: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case touchBundles = "supportedTabs"
        case inputTypes = "supportedInputTypes"
    }

    private struct TouchBundleReference: Decodable {
        let id: String?
    }

    public let touchBundleIDs: [String]
    public let inputTypes: [TitleInputType]

    public init(touchBundleIDs: [String], inputTypes: [TitleInputType]) {
        self.touchBundleIDs = touchBundleIDs
        self.inputTypes = inputTypes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let bundles = try container.decodeIfPresent(
            [TouchBundleReference].self,
            forKey: .touchBundles
        )

        touchBundleIDs = bundles?.compactMap(\.id) ?? []
        inputTypes = try container.decodeIfPresent([TitleInputType].self, forKey: .inputTypes) ?? []
    }
}

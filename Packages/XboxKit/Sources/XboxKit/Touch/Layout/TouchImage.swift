//
//  TouchImage.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchImage: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
        case opacity
        case label
    }

    private enum LabelKeys: String, CodingKey {
        case type
    }

    private enum SourceType: String {
        case icon
        case asset
        case color
    }

    public var source: TouchImageSource
    public var opacity: Double

    public init(source: TouchImageSource, opacity: Double = 1) {
        self.source = source
        self.opacity = opacity
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch SourceType(rawValue: type) {
        case .icon:
            let label = try? container.nestedContainer(keyedBy: LabelKeys.self, forKey: .label)
            let hiddenLabel = "none"
            let labelType = try label?.decodeIfPresent(String.self, forKey: .type)
            source = .icon(
                try container.decode(String.self, forKey: .value),
                showsActionLabel: labelType != hiddenLabel
            )
        case .asset: source = .asset(try container.decode(String.self, forKey: .value))
        case .color: source = .color(try container.decode(TouchColor.self, forKey: .value))
        case nil: source = .unsupported(type)
        }

        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1
    }
}

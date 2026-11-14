//
//  TouchControl.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchControl: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case isVisible = "visible"
        case isEnabled = "enabled"
    }

    public var kind: TouchControlKind
    public var isVisible: Bool
    public var isEnabled: Bool
    public var styles: [TouchStyleState: TouchControlStyle]

    public init(
        kind: TouchControlKind,
        isVisible: Bool = true,
        isEnabled: Bool = true,
        styles: [TouchStyleState: TouchControlStyle] = [:]
    ) {
        self.kind = kind
        self.isVisible = isVisible
        self.isEnabled = isEnabled
        self.styles = styles
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? ""
        let defaults = TouchControl(kind: .blank)

        kind = .init(type: type, decoder: decoder)
        isVisible =
            (try? container.decodeIfPresent(Bool.self, forKey: .isVisible)) ?? defaults.isVisible
        isEnabled =
            (try? container.decodeIfPresent(Bool.self, forKey: .isEnabled)) ?? defaults.isEnabled
        styles = (try? TouchStyleFields(from: decoder).styles) ?? defaults.styles
    }
}

//
//  TouchStyleFields.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

struct TouchStyleFields: Decodable {
    private enum CodingKeys: String, CodingKey {
        case styles
        case legacyIcon = "icon"
    }

    private struct StateKey: CodingKey {
        let stringValue: String
        let intValue: Int? = nil

        init(_ state: TouchStyleState) {
            stringValue = state.rawValue
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            nil
        }
    }

    let styles: [TouchStyleState: TouchControlStyle]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stateStyles = try? container.nestedContainer(keyedBy: StateKey.self, forKey: .styles)
        var styles: [TouchStyleState: TouchControlStyle] = [:]

        for state in TouchStyleState.allCases {
            styles[state] = try? stateStyles?.decodeIfPresent(
                TouchControlStyle.self,
                forKey: StateKey(state)
            )
        }

        let legacyIcon = try? container.decodeIfPresent(String.self, forKey: .legacyIcon)
        let hasDefaultFaceImage = styles[.default]?.faceImage != nil
        if let legacyIcon, !hasDefaultFaceImage {
            styles[.default, default: .init()].faceImage = .init(
                source: .icon(legacyIcon, showsActionLabel: true)
            )
        }

        self.styles = styles
    }
}

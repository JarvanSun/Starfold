//
//  TouchPullAction.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchPullAction: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case items
    }

    case actions([TouchAction])
    case segmented([[TouchAction]])

    public init(from decoder: Decoder) throws {
        let segmentedType = "segmented"
        let object = try? decoder.container(keyedBy: CodingKeys.self)
        let type = try? object?.decode(String.self, forKey: .type)

        switch (object, type == segmentedType) {
        case (let object?, true):
            let segments = try object.decode([OneOrMany<TouchAction>].self, forKey: .items)
            self = .segmented(segments.map(\.elements))
        default: self = .actions(try OneOrMany<TouchAction>(from: decoder).elements)
        }
    }
}

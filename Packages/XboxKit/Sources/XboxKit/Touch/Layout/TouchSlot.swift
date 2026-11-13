//
//  TouchSlot.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchSlot: Sendable, Hashable, Decodable {
    case empty
    case control(TouchControl)
    case cluster([TouchControl?])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let cluster = try? container.decode([TouchControl?].self)

        switch (container.decodeNil(), cluster) {
        case (true, _): self = .empty
        case (false, let cluster?): self = .cluster(cluster)
        case (false, nil): self = .control(try container.decode(TouchControl.self))
        }
    }
}

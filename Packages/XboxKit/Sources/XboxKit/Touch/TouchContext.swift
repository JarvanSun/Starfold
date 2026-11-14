//
//  TouchContext.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchContext: Sendable, Hashable {
    private let members: [String: JSONValue]
    private let stateKey = "state"

    public var state: JSONValue {
        members[stateKey] ?? .object([:])
    }

    var document: JSONValue {
        .object(members)
    }

    public init() {
        self.members = [:]
    }

    init(members: [String: JSONValue]) {
        self.members = members
    }

    public func applying(_ patch: JSONPatch) throws(JSONPatchError) -> TouchContext {
        var patched = members
        patched[stateKey] = try patch.applied(to: state)
        return .init(members: patched)
    }
}

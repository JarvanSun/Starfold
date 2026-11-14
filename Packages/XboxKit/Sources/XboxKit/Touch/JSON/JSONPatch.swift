//
//  JSONPatch.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct JSONPatch: Sendable, Hashable, Decodable {
    public let operations: [JSONPatchOperation]

    public init(operations: [JSONPatchOperation]) {
        self.operations = operations
    }

    public init(from decoder: Decoder) throws {
        operations = try decoder.singleValueContainer().decode([JSONPatchOperation].self)
    }

    public func applied(to document: JSONValue) throws(JSONPatchError) -> JSONValue {
        var patched = document

        for operation in operations {
            patched = try applying(operation, to: patched)
        }

        return patched
    }

    private func applying(
        _ operation: JSONPatchOperation,
        to document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        switch operation {
        case .add(let path, let value): try adding(value, at: path, in: document)
        case .remove(let path): try removing(at: path, in: document)
        case .replace(let path, let value): try replacing(at: path, with: value, in: document)
        case .move(let from, let path): try moving(from: from, to: path, in: document)
        case .copy(let from, let path):
            try adding(existing(at: from, in: document), at: path, in: document)
        case .test(let path, let value): try testing(value, at: path, in: document)
        }
    }

    private func adding(
        _ value: JSONValue,
        at path: JSONPointer,
        in document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        guard let token = path.tokens.last else { return value }

        let parent = try existingParent(of: path, in: document)
        let changedParent = try inserting(value, named: token, into: parent, at: path)
        return try replacingValue(at: path.parent, with: changedParent, in: document)
    }

    private func existingParent(
        of path: JSONPointer,
        in document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        guard let parent = path.parent.value(in: document) else {
            throw .pathNotFound(path.description)
        }

        return parent
    }

    private func inserting(
        _ value: JSONValue,
        named token: String,
        into parent: JSONValue,
        at path: JSONPointer
    ) throws(JSONPatchError) -> JSONValue {
        let appendToken = "-"

        switch (parent, token == appendToken, path.arrayIndex(from: token)) {
        case (.object(var members), _, _):
            members[token] = value
            return .object(members)
        case (.array(var elements), true, _):
            elements.append(value)
            return .array(elements)
        case (.array(var elements), false, let index?) where index <= elements.count:
            elements.insert(value, at: index)
            return .array(elements)
        case (.array, _, _): throw .invalidArrayIndex(path.description)
        default: throw .pathNotFound(path.description)
        }
    }

    private func replacingValue(
        at path: JSONPointer,
        with value: JSONValue,
        in document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        guard let first = path.tokens.first else { return value }

        let rest = JSONPointer(tokens: Array(path.tokens.dropFirst()))
        let child = try existing(at: JSONPointer(tokens: [first]), in: document)
        let changedChild = try replacingValue(at: rest, with: value, in: child)

        switch (document, path.arrayIndex(from: first)) {
        case (.object(var members), _):
            members[first] = changedChild
            return .object(members)
        case (.array(var elements), let index?):
            elements[index] = changedChild
            return .array(elements)
        default: throw .pathNotFound(path.description)
        }
    }

    private func existing(at path: JSONPointer, in document: JSONValue) throws(JSONPatchError)
        -> JSONValue
    {
        guard let value = path.value(in: document) else { throw .pathNotFound(path.description) }

        return value
    }

    private func removing(
        at path: JSONPointer,
        in document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        guard let token = path.tokens.last else { throw .pathNotFound(path.description) }

        let parent = try existingParent(of: path, in: document)
        let changedParent = try deleting(named: token, from: parent, at: path)
        return try replacingValue(at: path.parent, with: changedParent, in: document)
    }

    private func deleting(
        named token: String,
        from parent: JSONValue,
        at path: JSONPointer
    ) throws(JSONPatchError) -> JSONValue {
        switch (parent, path.arrayIndex(from: token)) {
        case (.object(var members), _) where members[token] != nil:
            members[token] = nil
            return .object(members)
        case (.array(var elements), let index?) where elements.indices.contains(index):
            elements.remove(at: index)
            return .array(elements)
        case (.array, _): throw .invalidArrayIndex(path.description)
        default: throw .pathNotFound(path.description)
        }
    }

    private func replacing(
        at path: JSONPointer,
        with value: JSONValue,
        in document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        guard !path.tokens.isEmpty else { return value }

        return try adding(value, at: path, in: removing(at: path, in: document))
    }

    private func moving(
        from: JSONPointer,
        to path: JSONPointer,
        in document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        guard !from.isProperPrefix(of: path) else { throw .moveIntoDescendant(path.description) }

        let value = try existing(at: from, in: document)
        guard from != path else { return document }

        return try adding(value, at: path, in: removing(at: from, in: document))
    }

    private func testing(
        _ value: JSONValue,
        at path: JSONPointer,
        in document: JSONValue
    ) throws(JSONPatchError) -> JSONValue {
        guard try existing(at: path, in: document) == value else {
            throw .testFailed(path.description)
        }

        return document
    }
}

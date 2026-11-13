//
//  TouchReferenceResolver.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

struct TouchReferenceResolver {
    private enum Source: String {
        case layout
        case context
    }

    private let layout: JSONValue
    private let context: JSONValue
    private let referenceKey = "$ref"
    private let definitionsKey = "definitions"
    private let contextFileName = "context.json"

    init(layout: JSONValue, context: JSONValue) {
        self.layout = layout
        self.context = context
    }

    func resolvedLayout() throws(TouchLayoutError) -> JSONValue {
        guard case .object(var members) = layout else {
            throw .invalidLayout("The layout is not a JSON object")
        }

        members[definitionsKey] = nil
        return try resolved(.object(members), in: .layout, following: [])
    }

    private func resolved(
        _ value: JSONValue,
        in source: Source,
        following chain: [String]
    ) throws(TouchLayoutError) -> JSONValue {
        switch (value, reference(in: value)) {
        case (_, let reference?): return try target(of: reference, from: source, following: chain)
        case (.array(let elements), nil):
            var resolvedElements: [JSONValue] = []

            for element in elements {
                resolvedElements.append(try resolved(element, in: source, following: chain))
            }

            return .array(resolvedElements)
        case (.object(let members), nil):
            var resolvedMembers: [String: JSONValue] = [:]

            for (key, member) in members {
                resolvedMembers[key] = try resolved(member, in: source, following: chain)
            }

            return .object(resolvedMembers)
        default: return value
        }
    }

    private func reference(in value: JSONValue) -> String? {
        switch value[referenceKey] {
        case .string(let reference)?: reference
        default: nil
        }
    }

    private func target(
        of reference: String,
        from source: Source,
        following chain: [String]
    ) throws(TouchLayoutError) -> JSONValue {
        let parts = reference.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let file = String(parts[0])
        let fragment = parts.dropFirst().first.map(String.init) ?? ""
        let pointerText = fragment.removingPercentEncoding ?? fragment
        let targetSource = try self.source(of: file, from: source, for: reference)
        let link = targetSource.rawValue + "#" + pointerText
        guard !chain.contains(link) else { throw .referenceCycle(reference) }

        let pointer = try? JSONPointer(pointerText)
        guard let value = pointer?.value(in: document(of: targetSource)) else {
            throw .unresolvedReference(reference)
        }

        return try resolved(value, in: targetSource, following: chain + [link])
    }

    private func source(
        of file: String,
        from source: Source,
        for reference: String
    ) throws(TouchLayoutError) -> Source {
        let isContextFile = file.lowercased().hasSuffix(contextFileName)

        switch (file.isEmpty, isContextFile) {
        case (true, _): return source
        case (false, true): return .context
        case (false, false): throw .unresolvedReference(reference)
        }
    }

    private func document(of source: Source) -> JSONValue {
        switch source {
        case .layout: layout
        case .context: context
        }
    }
}

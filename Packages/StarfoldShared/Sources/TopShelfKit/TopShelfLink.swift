//
//  TopShelfLink.swift
//  TopShelfKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public nonisolated enum TopShelfLink: Equatable, Sendable {
    private enum Scheme: String {
        case starfold
    }

    private enum Host: String {
        case game
        case console
    }

    private enum QueryKey: String {
        case name
        case play
    }

    private enum PlayFlag: String {
        case on = "1"
    }

    case game(id: String, name: String, shouldPlay: Bool)
    case console(id: String, name: String)

    public var url: URL {
        var components = URLComponents()
        components.scheme = Scheme.starfold.rawValue
        components.host = host.rawValue
        components.path = "/" + id
        components.queryItems = queryItems

        let schemeOnlyURL: URL = .init(string: "starfold:")!

        return components.url ?? schemeOnlyURL
    }

    public init?(url: URL) {
        guard
            url.scheme == Scheme.starfold.rawValue,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let id = components.linkID,
            let host = components.host.flatMap(Host.init(rawValue:))
        else {
            return nil
        }

        let name = components.firstValue(of: QueryKey.name.rawValue) ?? id

        switch host {
        case .game:
            let shouldPlay = components.contains(
                QueryKey.play.rawValue,
                value: PlayFlag.on.rawValue
            )
            self = .game(id: id, name: name, shouldPlay: shouldPlay)
        case .console: self = .console(id: id, name: name)
        }
    }
}

nonisolated private extension TopShelfLink {
    var id: String {
        switch self {
        case .game(let id, _, _), .console(let id, _): id
        }
    }

    var queryItems: [URLQueryItem] {
        let playItem: URLQueryItem = .init(
            name: QueryKey.play.rawValue,
            value: PlayFlag.on.rawValue
        )

        return switch self {
        case .game(_, let name, shouldPlay: true): [nameItem(name), playItem]
        case .game(_, let name, shouldPlay: false), .console(_, let name): [nameItem(name)]
        }
    }

    private var host: Host {
        switch self {
        case .game: .game
        case .console: .console
        }
    }

    func nameItem(_ name: String) -> URLQueryItem {
        .init(name: QueryKey.name.rawValue, value: name)
    }
}

nonisolated private extension URLComponents {
    var linkID: String? {
        let id = String(path.dropFirst())
        let isSingleSegment = !id.isEmpty && !id.contains("/")
        return isSingleSegment ? id : nil
    }

    func firstValue(of name: String) -> String? {
        queryItems?.first { $0.name == name }?.value
    }

    func contains(_ name: String, value: String) -> Bool {
        queryItems?.contains { $0.name == name && $0.value == value } ?? false
    }
}

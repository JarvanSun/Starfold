//
//  SystemDialogRequest.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct SystemDialogRequest: Equatable, Sendable, Identifiable {
    public enum Kind: Equatable, Sendable {
        case message(
            title: String,
            text: String,
            buttons: [String],
            defaultIndex: Int,
            cancelIndex: Int?
        )
        case keyboard(title: String, description: String, defaultText: String, maxLength: Int?)
    }

    public let id: String
    public let kind: Kind

    public init(id: String, kind: Kind) {
        self.id = id
        self.kind = kind
    }
}

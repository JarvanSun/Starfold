//
//  AccountSummary.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct AccountSummary: Identifiable, Equatable {
    public var id: String
    public var gamertag: String

    public init(id: String, gamertag: String) {
        self.id = id
        self.gamertag = gamertag
    }
}

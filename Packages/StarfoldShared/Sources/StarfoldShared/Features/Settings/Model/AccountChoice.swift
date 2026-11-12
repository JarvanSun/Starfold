//
//  AccountChoice.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct AccountChoice: Identifiable, Equatable {
    public let id: String
    public let gamertag: String
    public let isActive: Bool

    public init(id: String, gamertag: String, isActive: Bool) {
        self.id = id
        self.gamertag = gamertag
        self.isActive = isActive
    }
}

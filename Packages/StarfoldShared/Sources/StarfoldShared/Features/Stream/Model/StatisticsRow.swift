//
//  StatisticsRow.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct StatisticsRow: Equatable, Identifiable {
    public let kind: StatisticsRowKind
    public let value: String

    public var id: StatisticsRowKind {
        kind
    }
}

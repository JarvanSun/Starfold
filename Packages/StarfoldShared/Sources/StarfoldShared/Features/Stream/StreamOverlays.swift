//
//  StreamOverlays.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct StreamOverlays {
    let statisticsRows: [StatisticsRowKind]
    let controlsHideDelay: Duration?

    public init(statisticsRows: [StatisticsRowKind], controlsHideDelay: Duration?) {
        self.statisticsRows = statisticsRows
        self.controlsHideDelay = controlsHideDelay
    }
}

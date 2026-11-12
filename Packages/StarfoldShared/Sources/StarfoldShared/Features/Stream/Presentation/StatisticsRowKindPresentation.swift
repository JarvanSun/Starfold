//
//  StatisticsRowKindPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension StatisticsRowKind {
    public var label: LocalizedStringResource? {
        switch self {
        case .resolution: .init("stream.statistics.row.resolution", bundle: .module)
        case .codec: .init("stream.statistics.row.codec", bundle: .module)
        case .upscaled: .init("stream.statistics.row.upscaled", bundle: .module)
        case .dynamicRange: .init("stream.statistics.row.dynamicRange", bundle: .module)
        case .lowered: nil
        case .frameRate: .init("stream.statistics.row.frameRate", bundle: .module)
        case .bitrate: .init("stream.statistics.row.bitrate", bundle: .module)
        case .network: .init("stream.statistics.row.network", bundle: .module)
        case .roundTrip: .init("stream.statistics.row.roundTrip", bundle: .module)
        case .decode: .init("stream.statistics.row.decode", bundle: .module)
        case .jitterBuffer: .init("stream.statistics.row.jitterBuffer", bundle: .module)
        case .display: .init("stream.statistics.row.display", bundle: .module)
        case .packetLoss: .init("stream.statistics.row.packetLoss", bundle: .module)
        }
    }
}

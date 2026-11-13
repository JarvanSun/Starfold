//
//  NetworkPathPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import StreamKit

extension StreamStatistics.NetworkPath {
    var title: LocalizedStringResource {
        switch self {
        case .local: .init("stream.statistics.network.local", bundle: .module)
        case .internet: .init("stream.statistics.network.internet", bundle: .module)
        case .relay: .init("stream.statistics.network.relay", bundle: .module)
        }
    }
}

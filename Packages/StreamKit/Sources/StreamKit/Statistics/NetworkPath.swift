//
//  NetworkPath.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

extension StreamStatistics {
    public enum NetworkPath: Sendable, Equatable {
        case local
        case internet
        case relay

        init(localType: String?, remoteType: String?) {
            let isRelayed = localType == "relay" || remoteType == "relay"
            let isLocal = localType == "host" && remoteType == "host"
            self =
                switch (isRelayed, isLocal) {
                case (true, _): .relay
                case (false, true): .local
                case (false, false): .internet
                }
        }
    }
}

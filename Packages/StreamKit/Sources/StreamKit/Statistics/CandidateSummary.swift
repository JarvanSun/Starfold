//
//  CandidateSummary.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct CandidateSummary {
    let text: String

    init(statistics: [String: NSObject]?) {
        guard let statistics else {
            text = "?"

            return
        }

        let type = statistics["candidateType"] as? String ?? "?"
        let transport = statistics["protocol"] as? String ?? "?"
        let address = (statistics["address"] as? String) ?? (statistics["ip"] as? String) ?? "?"
        let port = (statistics["port"] as? NSNumber)?.intValue ?? 0
        let network = (statistics["networkType"] as? String).map { " \($0)" } ?? ""
        text = "\(transport) \(type) \(address):\(port)\(network)"
    }
}

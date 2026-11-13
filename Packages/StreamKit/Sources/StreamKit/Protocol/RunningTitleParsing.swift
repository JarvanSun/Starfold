//
//  RunningTitleParsing.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension RunningTitle {
    init?(content: [String: Any]) {
        let fields = Dictionary(
            content.map { ($0.key.lowercased(), $0.value) },
            uniquingKeysWith: { first, _ in first }
        )
        let titleID: String? =
            switch fields["titleid"] {
            case let text as String: text
            case let number as NSNumber: String(number.uint32Value, radix: 16, uppercase: true)
            default: nil
            }
        guard let titleID, !titleID.isEmpty else { return nil }

        self.init(titleID: titleID, isFocused: fields["focus"] as? Bool ?? true)
    }
}

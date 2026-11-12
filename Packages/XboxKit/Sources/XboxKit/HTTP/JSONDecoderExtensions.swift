//
//  JSONDecoderExtensions.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension JSONDecoder {
    convenience init(dateParser: XboxDateParser) {
        self.init()

        dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)
            guard let date = dateParser.date(from: text) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unrecognized date \(text)"
                )
            }

            return date
        }
    }
}

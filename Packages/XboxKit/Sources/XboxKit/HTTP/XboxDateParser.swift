//
//  XboxDateParser.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct XboxDateParser: Sendable {
    private let fractionalSecondsFormat = Date.ISO8601FormatStyle(includingFractionalSeconds: true)

    func date(from text: String) -> Date? {
        (try? fractionalSecondsFormat.parse(text))
            ?? textTrimmedToMilliseconds(text).flatMap { try? fractionalSecondsFormat.parse($0) }
            ?? (try? Date.ISO8601FormatStyle().parse(text))
    }

    private func textTrimmedToMilliseconds(_ text: String) -> String? {
        guard
            let dot = text.firstIndex(of: "."),
            let zone = text[dot...].firstIndex(where: isZoneDesignator)
        else {
            return nil
        }

        let milliseconds = text[text.index(after: dot)..<zone].prefix(3)
        return String(text[..<dot] + "." + milliseconds + text[zone...])
    }

    private func isZoneDesignator(_ character: Character) -> Bool {
        character == "Z" || character == "+" || character == "-"
    }
}

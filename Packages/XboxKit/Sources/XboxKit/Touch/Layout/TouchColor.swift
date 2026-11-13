//
//  TouchColor.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchColor: Sendable, Hashable, Decodable {
    case rgba(red: Double, green: Double, blue: Double, alpha: Double)
    case palette(String)
    case unsupported(String)

    public init(text: String) {
        let palettePrefix = "colors/"
        let hexColor = HexColor(text: text)

        switch (hexColor, text.hasPrefix(palettePrefix)) {
        case (let hexColor?, _):
            self = .rgba(
                red: hexColor.red,
                green: hexColor.green,
                blue: hexColor.blue,
                alpha: hexColor.alpha
            )
        case (nil, true): self = .palette(String(text.dropFirst(palettePrefix.count)))
        case (nil, false): self = .unsupported(text)
        }
    }

    public init(from decoder: Decoder) throws {
        self.init(text: try decoder.singleValueContainer().decode(String.self))
    }
}

private struct HexColor {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init?(text: String) {
        let digits = Array(text.dropFirst())
        let digitsPerComponent: Int? =
            switch digits.count {
            case 3, 4: 1
            case 6, 8: 2
            default: nil
            }
        let isHex = text.hasPrefix("#") && digits.allSatisfy(\.isHexDigit)
        guard isHex, let digitsPerComponent else { return nil }

        let hexRadix = 16
        let components = stride(from: 0, to: digits.count, by: digitsPerComponent).map { start in
            let component = String(digits[start..<(start + digitsPerComponent)])
            let fullWidth = digitsPerComponent == 1 ? component + component : component
            return Double(UInt8(fullWidth, radix: hexRadix) ?? 0) / Double(UInt8.max)
        }
        let opaque = 1.0

        red = components[0]
        green = components[1]
        blue = components[2]
        alpha = components.count > 3 ? components[3] : opaque
    }
}

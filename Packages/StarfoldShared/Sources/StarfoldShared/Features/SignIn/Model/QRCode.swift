//
//  QRCode.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreImage.CIFilterBuiltins
import Foundation

public struct QRCode: Equatable {
    public let image: CGImage?

    let url: URL

    init(url: URL) {
        self.url = url
        image = QRCodeRenderer().image(for: url)
    }

    public static func == (lhs: QRCode, rhs: QRCode) -> Bool {
        lhs.url == rhs.url
    }
}

private struct QRCodeRenderer {
    let correctionLevel = "M"
    let scale = CGAffineTransform(scaleX: 8, y: 8)

    func image(for url: URL) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.absoluteString.utf8)
        filter.correctionLevel = correctionLevel

        guard let output = filter.outputImage?.transformed(by: scale) else { return nil }

        return CIContext().createCGImage(output, from: output.extent)
    }
}

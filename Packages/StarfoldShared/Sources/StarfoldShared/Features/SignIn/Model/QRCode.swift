//
//  QRCode.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreImage.CIFilterBuiltins
import Foundation

public struct QRCode: Equatable {
    let url: URL

    public var image: CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.absoluteString.utf8)
        filter.correctionLevel = correctionLevel

        guard let output = filter.outputImage?.transformed(by: scale) else { return nil }

        return CIContext().createCGImage(output, from: output.extent)
    }
}

private extension QRCode {
    var correctionLevel: String {
        "M"
    }

    var scale: CGAffineTransform {
        .init(scaleX: 8, y: 8)
    }
}

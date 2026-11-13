//
//  CGImageExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

extension CGImage {
    func jpegData(quality: Double) -> Data? {
        let data = NSMutableData()
        let type = UTType.jpeg.identifier as CFString
        guard let destination = CGImageDestinationCreateWithData(data, type, 1, nil) else {
            return nil
        }

        let properties = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, self, properties)

        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }
}

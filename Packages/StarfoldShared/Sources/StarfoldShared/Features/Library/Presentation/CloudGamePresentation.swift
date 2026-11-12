//
//  CloudGamePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension CloudGame {
    public var tileArtwork: URL? {
        product?.tileImage ?? product?.posterImage
    }

    public var coverArtwork: URL? {
        product?.posterImage ?? product?.tileImage
    }

    public var heroArtwork: URL? {
        product?.heroImage ?? product?.titledHeroImage
    }

    public var titledHeroArtwork: URL? {
        product?.titledHeroImage ?? product?.heroImage ?? product?.posterImage
    }
}

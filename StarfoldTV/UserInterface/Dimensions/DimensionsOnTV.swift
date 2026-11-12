//
//  DimensionsOnTV.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import StarfoldShared

extension Dimensions {
    var gameArtworkHeight: CGFloat { 230 }
    var gameTileMinimumWidth: CGFloat { 260 }
    var gameShelfTileWidth: CGFloat { 360 }
    var gameShelfArtworkMaximumHeight: CGFloat { 184 }
    var gameHeroHeight: CGFloat { 360 }

    var homeCardMinimumWidth: CGFloat { 360 }
    var homeCardCaptionHeight: CGFloat { 110 }
    var homeCardStatusDotSize: CGFloat { 12 }

    var loadingCardWidth: CGFloat { 300 }
    var loadingCardHeight: CGFloat { 280 }
    var skeletonTitleLineHeight: CGFloat { 32 }
    var skeletonTextLineHeight: CGFloat { 24 }

    var welcomeIntroductionMaximumWidth: CGFloat { 860 }
    var welcomeAppSymbolPointSize: CGFloat { 52 }
    var welcomeAppSymbolBackgroundSize: CGFloat { 116 }
    var welcomeHeadlinePointSize: CGFloat { 66 }
    var welcomeFeatureSymbolBackgroundSize: CGFloat { 64 }
    var welcomePanelWidth: CGFloat { 700 }

    var signInQRCodeSize: CGFloat { 300 }
    var signInQRCodeBackgroundSize: CGFloat { signInQRCodeSize + 2 * spaceXLarge }
    var signInUserCodePointSize: CGFloat { 64 }
    var signInPlaceholderInstructionWidth: CGFloat { 440 }
    var signInPlaceholderCodeWidth: CGFloat { 380 }
    var signInStatusMinimumHeight: CGFloat { 500 }
    var signInStatusSymbolPointSize: CGFloat { 96 }

    var streamStatusMaximumWidth: CGFloat { 1100 }
    var streamMenuWidth: CGFloat { 640 }
    var gameDialogMinimumWidth: CGFloat { 700 }
    var gameTextPromptWidth: CGFloat { 1100 }
    var gameTextPromptHeight: CGFloat { 620 }

    func homeCardPictureHeight(width: CGFloat) -> CGFloat {
        width * 9 / 16
    }

    func homeCardHeight(width: CGFloat) -> CGFloat {
        homeCardPictureHeight(width: width) + homeCardCaptionHeight
    }
}

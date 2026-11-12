//
//  DimensionsOnVision.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import StarfoldShared

extension Dimensions {
    var mainWindowMinimumWidth: CGFloat { 860 }
    var mainWindowMaximumWidth: CGFloat { 1800 }
    var mainWindowMinimumHeight: CGFloat { 600 }
    var mainWindowMaximumHeight: CGFloat { 1200 }

    var readableTextMaximumWidth: CGFloat { 640 }
    var statusSymbolSize: CGFloat { 56 }

    var welcomeSymbolSize: CGFloat { 52 }
    var welcomeSymbolBackgroundSize: CGFloat { 112 }
    var welcomeFeatureIconSize: CGFloat { 52 }
    var welcomeSignInCardWidth: CGFloat { 480 }

    var signInSheetWidth: CGFloat { 560 }
    var signInSheetHeight: CGFloat { 460 }
    var signInCodeBoxWidth: CGFloat { 44 }
    var signInCodeBoxHeight: CGFloat { 56 }
    var signInCodeFontSize: CGFloat { 30 }
    var signInOutlineButtonWidth: CGFloat { 260 }
    var signInOutlineButtonHeight: CGFloat { 60 }
    var signInOutlineTextWidth: CGFloat { 320 }
    var signInOutlineTextHeight: CGFloat { 14 }
    var signInOutlineCodeWidth: CGFloat { 380 }

    var accountPictureSize: CGFloat { 32 }
    var consoleCardWidth: CGFloat { 400 }
    var consoleCardHeight: CGFloat { 360 }
    var consoleCardArtworkHeight: CGFloat { consoleCardWidth * 9 / 16 }
    var consoleModelNameFontSize: CGFloat { 32 }
    var consolePowerButtonSize: CGFloat { 44 }

    var gameTileWidth: CGFloat { 180 }
    var gameGridColumnMaximumWidth: CGFloat { gameTileWidth + spaceXXXLarge }
    var gameFactsWidth: CGFloat { 260 }
    var gameScreenshotHeight: CGFloat { 220 }

    var streamBackdropBlurRadius: CGFloat { 40 }
    var streamOptionsWidth: CGFloat { 440 }
    var gameDialogWidth: CGFloat { 520 }
    var gameTextPromptHeight: CGFloat { 320 }
}

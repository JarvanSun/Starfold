//
//  DimensionsOniOS.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import StarfoldShared
import SwiftUI

extension Dimensions {
    var welcomeSideBySideMinimumWidth: CGFloat { 820 }
    var welcomeSideBySideMinimumHeight: CGFloat { 600 }

    var accountPictureSize: CGFloat { 32 }

    var homeCardWidth: CGFloat { 300 }
    var homeCardHeight: CGFloat { 356 }
    var homeCardArtworkHeight: CGFloat { 220 }
    var consoleModelNameSize: CGFloat { 28 }
    var messageSymbolSize: CGFloat { 44 }
    var recentGameTileWidth: CGFloat { 108 }

    var skeletonTitleWidth: CGFloat { 160 }
    var skeletonTitleHeight: CGFloat { 14 }
    var skeletonSubtitleWidth: CGFloat { 110 }
    var skeletonSubtitleHeight: CGFloat { 10 }
    var skeletonButtonWidth: CGFloat { 56 }

    var gameTileWidth: CGFloat { 104 }
    var gameTileMaximumWidth: CGFloat { 168 }
    var gameTilePlayIconSize: CGFloat { 16 }

    var gameHeroHeight: CGFloat { 380 }
    var gameHeroOverlap: CGFloat { 90 }
    var gameTitleSize: CGFloat { 34 }
    var publisherMonogramSize: CGFloat { 22 }
    var gamePlayButtonMinimumWidth: CGFloat { 120 }
    var gameFavoriteButtonSize: CGFloat { 46 }
    var gameDescriptionMaxWidth: CGFloat { 640 }
    var gameFactsWidth: CGFloat { 240 }
    var gameScreenshotHeight: CGFloat { 190 }

    var welcomeTitleSize: CGFloat { 38 }
    var welcomePitchMaxWidth: CGFloat { 520 }
    var welcomeGlyphSize: CGFloat { 96 }
    var welcomeCompactGlyphSize: CGFloat { 56 }
    var welcomePanelWidth: CGFloat { 420 }
    var welcomeSheetMaxWidth: CGFloat { 480 }
    var welcomeFeatureSymbolSize: CGFloat { 44 }

    var signInStatusMinimumHeight: CGFloat { 300 }
    var signInPlaceholderButtonWidth: CGFloat { 260 }
    var codeCharacterSize: CGFloat { 26 }
    var codeBoxWidth: CGFloat { 34 }
    var codeBoxHeight: CGFloat { 48 }

    var streamStatusWidth: CGFloat { 560 }
    var streamTitleSize: CGFloat { 34 }
    var streamBackdropBlurRadius: CGFloat { 30 }
    var connectingIndicatorDiameter: CGFloat { 48 }
    var connectingIndicatorLineWidth: CGFloat { 4 }
    var gameDialogMinimumWidth: CGFloat { 320 }
    var streamMenuWidth: CGFloat { 440 }
    var streamMenuActionHeight: CGFloat { 52 }
    var streamMenuHandleWidth: CGFloat { 44 }
    var streamMenuHandleHeight: CGFloat { 22 }
    var highlightLineWidth: CGFloat { 2 }
    var touchEditorPanelWidth: CGFloat { 360 }
    var touchEditorSliderWidth: CGFloat { 160 }
    var touchPlaceholderDash: CGFloat { 6 }

    func touchMetrics(forVerticalSizeClass sizeClass: UserInterfaceSizeClass?) -> TouchMetrics {
        switch sizeClass {
        case .regular:
            .init(stickDiameter: 160, buttonDiameter: 64, smallButtonDiameter: 40, edgeMargin: 28)
        default:
            .init(stickDiameter: 124, buttonDiameter: 52, smallButtonDiameter: 36, edgeMargin: 16)
        }
    }
}

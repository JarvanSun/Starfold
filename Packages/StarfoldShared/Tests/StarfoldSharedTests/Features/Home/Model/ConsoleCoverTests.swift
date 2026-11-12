//
//  ConsoleCoverTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import Foundation
import Testing
import XboxKit

@testable import StarfoldShared

@MainActor
struct ConsoleCoverTests {
    @Test(arguments: [ConsoleActivity.Kind.playingNow, .lastPlayedHere])
    func initWhenConsoleHasLastFrameThenShowsItOverGameArt(kind: ConsoleActivity.Kind) {
        // Given / When
        let cover = ConsoleCover(activity: activity(kind), lastFrame: .dummyRedPixels)

        // Then
        #expect(CoverKind(cover) == .lastFrame)
    }

    @Test(arguments: [ConsoleActivity.Kind.playingNow, .lastPlayedHere])
    func initWhenConsoleHasNoLastFrameThenShowsGameArt(kind: ConsoleActivity.Kind) {
        // Given / When
        let cover = ConsoleCover(activity: activity(kind), lastFrame: nil)

        // Then
        #expect(CoverKind(cover) == .game)
    }

    @Test
    func initWhenNothingIsKnownThenShowsPlaceholder() {
        // Given / When
        let cover = ConsoleCover(activity: nil, lastFrame: nil)

        // Then
        #expect(CoverKind(cover) == .placeholder)
    }
}

private enum CoverKind {
    case game
    case lastFrame
    case placeholder

    init(_ cover: ConsoleCover) {
        switch cover {
        case .game: self = .game
        case .lastFrame: self = .lastFrame
        case .placeholder: self = .placeholder
        }
    }
}

private extension ConsoleCoverTests {
    func activity(_ kind: ConsoleActivity.Kind) -> ConsoleActivity {
        .init(
            titleID: "A",
            name: "A",
            imageURL: URL(string: "https://example.com/art.jpg")!,
            kind: kind
        )
    }
}

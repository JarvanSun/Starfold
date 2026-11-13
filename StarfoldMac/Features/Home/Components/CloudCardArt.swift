//
//  CloudCardArt.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CloudCardArt: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let covers: [URL]
    let access: CloudAccess
    let isLoading: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [palette.nightRaised.color, palette.night.color],
                startPoint: .top,
                endPoint: .bottom
            )

            switch covers.isEmpty {
            case true: placeholder
            case false: coverFan
            }
        }
        .animation(.smooth(duration: 0.5), value: covers)
    }
}

private extension CloudCardArt {
    var placeholder: some View {
        Image(systemName: access.placeholderSymbol)
            .font(.system(size: dimensions.cloudPlaceholderSymbolSize))
            .foregroundStyle(placeholderStyle)
            .symbolEffect(.pulse, isActive: isLoading)
    }

    var placeholderStyle: AnyShapeStyle {
        switch access {
        case .unavailable: .init(.secondary)
        case .gamePass, .freeToPlay, .unknown: .init(palette.primaryFill)
        }
    }

    var coverFan: some View {
        let middle = Double(covers.count - 1) / 2
        return ForEach(Array(covers.enumerated()), id: \.element) { index, url in
            cover(url, at: Double(index) - middle)
        }
        .transition(.opacity)
    }

    func cover(_ url: URL, at position: Double) -> some View {
        let isMiddle = position == 0
        let coverTilt: Double = 9

        return GameArtwork(url: url, aspectRatio: 2 / 3)
            .frame(width: dimensions.cloudCoverWidth)
            .shadow(
                color: .black.opacity(0.5),
                radius: dimensions.shadowRadiusMedium,
                y: dimensions.shadowOffsetMedium
            )
            .rotationEffect(.degrees(position * coverTilt), anchor: .bottom)
            .offset(
                x: position * dimensions.spaceHuge,
                y: isMiddle ? -dimensions.spaceSmall : dimensions.spaceSmall
            )
            .zIndex(isMiddle ? 1 : 0)
    }
}

#if DEBUG
#Preview {
    HStack {
        CloudCardArt(covers: [], access: .gamePass, isLoading: true)

        CloudCardArt(covers: [], access: .unavailable, isLoading: false)
    }
    .frame(height: 220)
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif

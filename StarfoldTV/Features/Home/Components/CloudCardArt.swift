//
//  CloudCardArt.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CloudCardArt: View {
    @Environment(\.dimensions) private var dimensions

    let covers: [URL]
    let access: CloudAccess
    let width: CGFloat

    var body: some View {
        ZStack {
            Color.cardFill

            switch covers.isEmpty {
            case true: placeholder
            case false: coverFan
            }
        }
    }
}

private extension CloudCardArt {
    var placeholder: some View {
        Image(systemName: access.placeholderSymbol)
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }

    var coverFan: some View {
        let middle = Double(covers.count - 1) / 2
        return ForEach(Array(covers.enumerated()), id: \.element) { index, url in
            cover(url, position: Double(index) - middle)
        }
    }

    func cover(_ url: URL, position: Double) -> some View {
        let coverWidthRatio: CGFloat = 0.32
        let coverHeightRatio: CGFloat = 0.46
        let fanAngle: Double = 9
        let fanSpreadRatio: CGFloat = 0.25

        return Artwork(url: url)
            .frame(width: width * coverWidthRatio, height: width * coverHeightRatio)
            .clipShape(.rect(cornerRadius: dimensions.cornerRadiusMedium))
            .rotationEffect(.degrees(position * fanAngle), anchor: .bottom)
            .offset(x: position * width * fanSpreadRatio, y: coverLift(at: position))
            .zIndex(position == 0 ? 1 : 0)
    }

    func coverLift(at position: Double) -> CGFloat {
        position == 0 ? -dimensions.spaceXSmall : dimensions.spaceMedium
    }
}

#if DEBUG
#Preview {
    HStack {
        CloudCardArt(covers: [], access: .gamePass, width: 480)

        CloudCardArt(covers: [], access: .unavailable, width: 480)
    }
    .frame(height: 270)
}
#endif

//
//  AppGlyph.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct AppGlyph: View {
    @Environment(\.palette) private var palette

    let size: CGFloat

    var body: some View {
        let glyphScale: CGFloat = 0.62
        let cornerScale: CGFloat = 0.225

        RoundedRectangle(cornerRadius: size * cornerScale, style: .continuous)
            .fill(palette.primaryFill)
            .overlay {
                Image(.appGlyph)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: size * glyphScale)
            }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    AppGlyph(size: 96)
        .padding()
}
#endif

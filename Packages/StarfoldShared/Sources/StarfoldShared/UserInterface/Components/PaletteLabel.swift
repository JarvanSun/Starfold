//
//  PaletteLabel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/17.
//

import SwiftUI

public struct PaletteLabel: View {
    @Environment(\.dimensions) private var dimensions

    private let palette: Palette

    public init(_ id: PaletteID) {
        palette = Palette(id)
    }

    public var body: some View {
        Label {
            Text(palette.name)
        } icon: {
            Circle()
                .fill(palette.primaryFill)
                .frame(width: dimensions.paletteSwatchSize, height: dimensions.paletteSwatchSize)
        }
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        ForEach(PaletteID.allCases, id: \.self) { PaletteLabel($0) }
    }
    .padding()
}
#endif

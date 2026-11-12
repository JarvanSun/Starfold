//
//  PalettePicker.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct PalettePicker: View {
    @Environment(\.dimensions) private var dimensions
    @Binding private var selection: PaletteID

    public init(selection: Binding<PaletteID>) {
        _selection = selection
    }

    public var body: some View {
        Picker(selection: $selection) {
            ForEach(palettes, content: option(for:))
        } label: {
            Text("palette.picker.title", bundle: .module)
        }
    }
}

private extension PalettePicker {
    var palettes: [Palette] {
        PaletteID.allCases.map(Palette.init)
    }

    func option(for palette: Palette) -> some View {
        Label {
            Text(palette.name)
        } icon: {
            Circle()
                .fill(palette.primaryFill)
                .frame(width: dimensions.paletteSwatchSize, height: dimensions.paletteSwatchSize)
        }
        .tag(palette.id)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection = PaletteID.nebula

    PalettePicker(selection: $selection)
        .padding()
}
#endif

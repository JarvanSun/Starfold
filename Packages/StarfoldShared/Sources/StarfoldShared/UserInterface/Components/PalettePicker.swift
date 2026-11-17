//
//  PalettePicker.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct PalettePicker: View {
    @Binding private var selection: PaletteID

    private let palettes: [PaletteID]

    public init(selection: Binding<PaletteID>, palettes: [PaletteID]) {
        _selection = selection
        self.palettes = palettes
    }

    public var body: some View {
        Picker(selection: $selection) {
            ForEach(palettes, id: \.self) { PaletteLabel($0).tag($0) }
        } label: {
            Text("palette.picker.title", bundle: .module)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection = PaletteID.nebula

    PalettePicker(selection: $selection, palettes: PaletteID.allCases)
        .padding()
}
#endif

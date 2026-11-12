//
//  SortPicker.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SortPicker: View {
    @Binding var sort: GameSort

    let choices: [GameSort]

    var body: some View {
        Picker("library.sort.title", selection: $sort) {
            ForEach(choices, id: \.self) { choice in
                Label(choice.title, systemImage: choice.symbol)
                    .tag(choice)
            }
        }
        .pickerStyle(.menu)
    }
}

#if DEBUG
#Preview("Sort picker") {
    @Previewable @State var sort = GameSort.name

    SortPicker(sort: $sort, choices: GameSort.allCases)
        .padding()
}
#endif

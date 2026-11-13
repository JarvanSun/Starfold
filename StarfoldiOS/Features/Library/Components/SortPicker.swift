//
//  SortPicker.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SortPicker: View {
    @Binding var sort: GameSort

    let choices: [GameSort]

    var body: some View {
        Menu {
            Picker(selection: $sort) {
                ForEach(choices, id: \.self) { choice in
                    Label(choice.title, systemImage: choice.symbol)
                        .tag(choice)
                }
            } label: {
                Text("library.sort.title")
            }
            .pickerStyle(.inline)
        } label: {
            Label("library.sort.title", systemImage: "arrow.up.arrow.down")
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var sort = GameSort.name

    SortPicker(sort: $sort, choices: GameSort.allCases)
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif

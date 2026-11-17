//
//  ChoiceLink.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/17.
//

import StarfoldShared
import SwiftUI

struct ChoiceLink<Choice: Hashable, Option: View>: View {
    @Binding var selection: Choice

    let title: LocalizedStringKey
    let choices: [Choice]
    let option: (Choice) -> Option

    init(
        _ title: LocalizedStringKey,
        selection: Binding<Choice>,
        choices: [Choice],
        @ViewBuilder option: @escaping (Choice) -> Option
    ) {
        self.title = title
        _selection = selection
        self.choices = choices
        self.option = option
    }

    var body: some View {
        NavigationLink {
            ChoiceList(selection: $selection, choices: choices, option: option)
                .navigationTitle(title)
        } label: {
            LabeledContent {
                option(selection)
            } label: {
                Text(title)
            }
        }
    }
}

private struct ChoiceList<Choice: Hashable, Option: View>: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedChoice: Choice?

    @Binding var selection: Choice
    let choices: [Choice]
    let option: (Choice) -> Option

    var body: some View {
        List(choices, id: \.self) { choice in
            CheckmarkButton(isChecked: choice == selection, onSelect: { choose(choice) }) {
                option(choice)
            }
            .focused($focusedChoice, equals: choice)
        }
        .defaultFocus($focusedChoice, selection)
    }

    private func choose(_ choice: Choice) {
        selection = choice

        dismiss()
    }
}

#if DEBUG
#Preview {
    @Previewable @State var palette = PaletteID.nebula

    NavigationStack {
        Form {
            ChoiceLink(
                "settings.appearance.palette",
                selection: $palette,
                choices: PaletteID.allCases
            ) { PaletteLabel($0) }
        }
    }
}
#endif

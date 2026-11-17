//
//  CheckmarkButton.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/17.
//

import SwiftUI

struct CheckmarkButton<Content: View>: View {
    let isChecked: Bool
    let content: Content

    let onSelect: () -> Void

    init(isChecked: Bool, onSelect: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isChecked = isChecked
        self.onSelect = onSelect
        self.content = content()
    }

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack {
                content

                Spacer()

                Image(systemName: "checkmark")
                    .opacity(isChecked ? 1 : 0)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityAddTraits(isChecked ? .isSelected : [])
    }
}

#if DEBUG
#Preview {
    List {
        CheckmarkButton(isChecked: true, onSelect: {}) { Text(verbatim: "Automatic") }

        CheckmarkButton(isChecked: false, onSelect: {}) { Text(verbatim: "1080p") }
    }
}
#endif

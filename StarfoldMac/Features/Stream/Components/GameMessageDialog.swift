//
//  GameMessageDialog.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameMessageDialog: View {
    @Environment(\.dimensions) private var dimensions

    let title: String
    let text: String
    let buttons: [DialogButton]

    let onAnswer: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            if !title.isEmpty {
                Text(title).font(.headline)
            }

            if !text.isEmpty {
                Text(text)
            }

            HStack {
                Spacer()

                ForEach(buttons) { button in
                    Button(button.title) { onAnswer(button.index) }
                        .keyboardShortcut(button.role.keyboardShortcut)
                }
            }
        }
        .padding(dimensions.spaceXLarge)
        .frame(minWidth: dimensions.gameDialogMinimumWidth)
    }

}

#if DEBUG
#Preview {
    GameMessageDialog(
        title: PreviewObjectPool.messageDialogTitle,
        text: PreviewObjectPool.messageDialogText,
        buttons: PreviewObjectPool.messageDialogButtons
    ) { _ in }
}
#endif

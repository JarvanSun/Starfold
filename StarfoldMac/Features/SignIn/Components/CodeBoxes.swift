//
//  CodeBoxes.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CodeBoxes: View {
    @Environment(\.dimensions) private var dimensions

    let code: SignInCode

    var body: some View {
        HStack(spacing: dimensions.spaceXSmall) {
            ForEach(code.characters, content: box(for:))
        }
        .textSelection(.enabled)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("signIn.code.accessibilityLabel \(code.spelledOut)"))
    }
}

private extension CodeBoxes {
    func box(for character: SignInCodeCharacter) -> some View {
        Text(verbatim: character.text)
            .font(.system(size: dimensions.codeCharacterSize, weight: .bold, design: .monospaced))
            .frame(width: dimensions.codeBoxWidth, height: dimensions.codeBoxHeight)
            .background(
                .white.opacity(0.08),
                in: .rect(cornerRadius: dimensions.cornerRadiusSmall)
            )
            .overlay(
                RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
                    .strokeBorder(.white.opacity(0.12))
            )
    }
}

#if DEBUG
#Preview {
    CodeBoxes(code: PreviewObjectPool.signInCode)
        .padding()
        .background(Palette(.nebula).night.color)
        .environment(\.colorScheme, .dark)
}
#endif

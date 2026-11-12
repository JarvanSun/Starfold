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
        HStack(spacing: dimensions.spaceSmall) {
            ForEach(code.characters) { box(for: $0) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("signIn.code.accessibilityLabel \(code.spelledOut)"))
    }
}

private extension CodeBoxes {
    func box(for character: SignInCodeCharacter) -> some View {
        Text(verbatim: character.text)
            .font(.system(size: dimensions.signInCodeFontSize, weight: .bold, design: .monospaced))
            .frame(width: dimensions.signInCodeBoxWidth, height: dimensions.signInCodeBoxHeight)
            .background(.regularMaterial, in: .rect(cornerRadius: dimensions.cornerRadiusMedium))
    }
}

#if DEBUG
#Preview {
    CodeBoxes(code: PreviewObjectPool.signInCode)
        .padding()
}
#endif

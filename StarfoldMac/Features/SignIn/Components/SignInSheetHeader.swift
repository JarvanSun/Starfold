//
//  SignInSheetHeader.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInSheetHeader: View {
    @Environment(\.dimensions) private var dimensions

    let onCancel: () -> Void

    var body: some View {
        HStack {
            Text("signIn.sheet.title")
                .font(.title3.bold())

            Spacer()

            Button(String(localized: "signIn.sheet.cancel")) { onCancel() }
                .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, dimensions.spaceXLarge)
        .padding(.vertical, dimensions.spaceMedium)
    }
}

#if DEBUG
#Preview {
    SignInSheetHeader {}
        .frame(width: 460)
}
#endif

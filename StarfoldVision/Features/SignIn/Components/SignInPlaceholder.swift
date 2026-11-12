//
//  SignInPlaceholder.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInPlaceholder: View {
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            Capsule()
                .fill(.quaternary)
                .frame(
                    width: dimensions.signInOutlineButtonWidth,
                    height: dimensions.signInOutlineButtonHeight
                )

            Capsule()
                .fill(.quaternary)
                .frame(
                    width: dimensions.signInOutlineTextWidth,
                    height: dimensions.signInOutlineTextHeight
                )

            RoundedRectangle(cornerRadius: dimensions.cornerRadiusMedium)
                .fill(.quaternary)
                .frame(
                    width: dimensions.signInOutlineCodeWidth,
                    height: dimensions.signInCodeBoxHeight
                )
        }
        .accessibilityElement()
        .accessibilityLabel(Text("signIn.outline.preparing"))
    }
}

#if DEBUG
#Preview {
    SignInPlaceholder()
        .padding()
}
#endif

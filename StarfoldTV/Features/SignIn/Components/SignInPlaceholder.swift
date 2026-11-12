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
        VStack(spacing: dimensions.spaceXXLarge) {
            RoundedRectangle(cornerRadius: dimensions.cornerRadiusXXLarge)
                .fill(Color.cardFill)
                .frame(
                    width: dimensions.signInQRCodeBackgroundSize,
                    height: dimensions.signInQRCodeBackgroundSize
                )

            Capsule()
                .fill(Color.cardFill)
                .frame(
                    width: dimensions.signInPlaceholderInstructionWidth,
                    height: dimensions.skeletonTextLineHeight
                )

            Capsule()
                .fill(Color.cardFill)
                .frame(
                    width: dimensions.signInPlaceholderCodeWidth,
                    height: dimensions.signInUserCodePointSize
                )
        }
        .accessibilityElement()
        .accessibilityLabel(Text("signIn.placeholder.label"))
    }
}

#if DEBUG
#Preview {
    SignInPlaceholder()
}
#endif

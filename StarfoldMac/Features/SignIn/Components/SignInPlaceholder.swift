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
        VStack(spacing: dimensions.spaceLarge) {
            Color.clear
                .frame(width: dimensions.qrCodeSize, height: dimensions.qrCodeSize)
                .padding(dimensions.spaceMedium)
                .background(Color.cardFill, in: .rect(cornerRadius: dimensions.cornerRadiusLarge))

            Capsule()
                .fill(Color.cardFill)
                .frame(width: dimensions.skeletonTitleWidth, height: dimensions.skeletonTitleHeight)

            codeBoxes

            Capsule()
                .fill(Color.cardFill)
                .frame(
                    width: dimensions.signInPlaceholderButtonWidth,
                    height: dimensions.circleButtonSize
                )
        }
        .accessibilityElement()
        .accessibilityLabel(Text("signIn.placeholder.accessibilityLabel"))
    }

    private var codeBoxes: some View {
        let codeLength = 8

        return HStack(spacing: dimensions.spaceXSmall) {
            ForEach(0..<codeLength, id: \.self) { _ in
                RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
                    .fill(Color.cardFill)
                    .frame(width: dimensions.codeBoxWidth, height: dimensions.codeBoxHeight)
            }
        }
    }
}

#if DEBUG
#Preview {
    SignInPlaceholder()
        .padding()
        .background(Palette(.nebula).night.color)
        .environment(\.colorScheme, .dark)
}
#endif

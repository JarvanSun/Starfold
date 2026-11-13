//
//  ConsoleSkeletons.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct ConsoleSkeletons: View {
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        HStack(spacing: dimensions.spaceXLarge) {
            skeleton

            skeleton
        }
    }

    private var skeleton: some View {
        RoundedRectangle(cornerRadius: dimensions.cornerRadiusXXLarge)
            .fill(.thinMaterial)
            .frame(width: dimensions.consoleCardWidth, height: dimensions.consoleCardHeight)
            .accessibilityLabel(Text("home.consoles.loading"))
    }
}

#if DEBUG
#Preview("Console skeletons") {
    ConsoleSkeletons()
        .padding()
}
#endif

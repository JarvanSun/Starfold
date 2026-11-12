//
//  WelcomeTrademark.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct WelcomeTrademark: View {
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        Text("welcome.trademark \(AppInfo().displayName)")
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, dimensions.spaceHuge)
            .padding(.bottom, dimensions.spaceXLarge)
    }
}

#if DEBUG
#Preview {
    WelcomeTrademark()
}
#endif

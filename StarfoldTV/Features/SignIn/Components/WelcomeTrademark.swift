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
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, dimensions.spaceXXXLarge)
            .offset(y: dimensions.spaceXXLarge)
    }
}

#if DEBUG
#Preview {
    WelcomeTrademark()
}
#endif

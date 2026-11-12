//
//  WelcomeTrademark.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct WelcomeTrademark: View {
    var body: some View {
        Text("welcome.trademark \(AppInfo().displayName)")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }
}

#if DEBUG
#Preview {
    WelcomeTrademark()
        .padding()
}
#endif

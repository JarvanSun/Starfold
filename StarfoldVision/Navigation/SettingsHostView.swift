//
//  SettingsHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct SettingsHostView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        NavigationStack {
            SettingsView(settings: app.settings)
        }
    }
}

#if DEBUG
#Preview("Settings") {
    SettingsHostView()
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

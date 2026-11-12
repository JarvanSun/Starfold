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

    let onAddAccount: () -> Void

    var body: some View {
        NavigationStack {
            SettingsView(settings: app.settings, onAddAccount: onAddAccount)
        }
    }
}

#if DEBUG
#Preview {
    SettingsHostView(onAddAccount: {})
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

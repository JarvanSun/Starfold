//
//  SettingsHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SettingsHostView: View {
    @Environment(AppViewModel.self) private var appViewModel

    let onAddAccount: () -> Void

    var body: some View {
        NavigationStack {
            SettingsView(settingsViewModel: appViewModel.settings, onAddAccount: onAddAccount)
        }
    }
}

#if DEBUG
#Preview("Settings") {
    SettingsHostView {}
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif

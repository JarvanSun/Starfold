//
//  SignedOutView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SignedOutView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            SignInHostView { WelcomeView(signInViewModel: $0) }
                .background { SkyBackground() }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("settings.title", systemImage: "gear") { isShowingSettings = true }
                    }
                }
        }
        .sheet(isPresented: $isShowingSettings) { settingsViewModel }
    }

    private var settingsViewModel: some View {
        NavigationStack {
            SettingsView(settingsViewModel: appViewModel.settingsViewModel, onAddAccount: {})
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .close) { isShowingSettings = false }
                    }
                }
        }
    }
}

#if DEBUG
#Preview {
    SignedOutView()
        .environment(PreviewObjectPool.appViewModel(signedIn: false))
}
#endif

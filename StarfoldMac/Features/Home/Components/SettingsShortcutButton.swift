//
//  SettingsShortcutButton.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SettingsShortcutButton: View {
    var body: some View {
        SettingsLink {
            Label(String(localized: "home.card.streamSettings"), systemImage: "slider.horizontal.3")
        }
        .buttonStyle(.circleIcon)
        .help(Text("home.card.streamSettings"))
    }
}

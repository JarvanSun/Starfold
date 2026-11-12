//
//  RestartStreamSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct RestartStreamSection: View {
    @Environment(\.dimensions) private var dimensions

    let onRestart: () -> Void

    var body: some View {
        Section {
            HStack(spacing: dimensions.spaceMedium) {
                Label {
                    Text("settings.streaming.restart.message")
                } icon: {
                    Image(systemName: "arrow.clockwise.circle.fill").foregroundStyle(.tint)
                }

                Spacer(minLength: dimensions.spaceSmall)

                Button(String(localized: "settings.streaming.restart.button"), action: onRestart)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        RestartStreamSection {}
    }
    .formStyle(.grouped)
}
#endif

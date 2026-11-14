//
//  StreamOptionsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct StreamOptionsView: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
            buffer

            sound
        }
        .pickerStyle(.segmented)
        .padding(dimensions.spaceXLarge)
        .frame(width: dimensions.streamOptionsWidth)
    }

    private var buffer: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text("stream.options.buffer")
                .font(.headline)

            Picker("stream.options.buffer", selection: $settingsViewModel.pacingMode) {
                ForEach(settingsViewModel.pacingModes, id: \.self) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
        }
    }

    private var sound: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text("stream.options.sound")
                .font(.headline)

            Picker("stream.options.sound", selection: $settingsViewModel.soundStage) {
                ForEach(settingsViewModel.soundStages, id: \.self) { stage in
                    Text(stage.title)
                        .tag(stage)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Stream options") {
    StreamOptionsView(settingsViewModel: PreviewObjectPool.settingsViewModel)
}
#endif

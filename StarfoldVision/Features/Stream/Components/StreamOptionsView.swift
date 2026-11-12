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
    @Bindable var settings: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
            buffer

            sound
        }
        .pickerStyle(.segmented)
        .padding(dimensions.spaceXLarge)
        .frame(width: dimensions.streamOptionsWidth)
    }
}

private extension StreamOptionsView {
    var buffer: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text("stream.options.buffer")
                .font(.headline)

            Picker("stream.options.buffer", selection: $settings.pacingMode) {
                ForEach(settings.pacingModes, id: \.self) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
        }
    }

    var sound: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text("stream.options.sound")
                .font(.headline)

            Picker("stream.options.sound", selection: $settings.soundStage) {
                ForEach(settings.soundStages, id: \.self) { stage in
                    Text(stage.title)
                        .tag(stage)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Stream options") {
    StreamOptionsView(settings: PreviewObjectPool.settingsViewModel)
}
#endif

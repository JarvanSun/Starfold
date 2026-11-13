//
//  TouchLayoutEditorPanel.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchLayoutEditorPanel: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var editor: TouchLayoutEditorViewModel

    let onDone: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceMedium) {
            slider("touchEditor.size", value: $editor.selectedScale, range: editor.scaleRange)
                .disabled(!editor.hasSelection)

            slider("touchEditor.opacity", value: $editor.opacity, range: editor.opacityRange)

            HStack {
                Button("touchEditor.reset", role: .destructive) { editor.reset() }

                Spacer()

                Button("touchEditor.done") { onDone() }
                    .buttonStyle(.glassProminent)
            }
        }
        .padding(dimensions.spaceLarge)
        .frame(maxWidth: dimensions.touchEditorPanelWidth)
        .glassEffect(in: .rect(cornerRadius: dimensions.cornerRadiusXLarge))
    }

    private func slider(
        _ title: LocalizedStringResource,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        LabeledContent {
            Slider(value: value, in: range)
                .frame(width: dimensions.touchEditorSliderWidth)
        } label: {
            Text(title)
        }
    }
}

#if DEBUG
#Preview {
    TouchLayoutEditorPanel(editor: PreviewObjectPool.settingsViewModel.touchLayoutEditor()) {}
        .padding()
        .background(.black)
        .environment(\.colorScheme, .dark)
}
#endif

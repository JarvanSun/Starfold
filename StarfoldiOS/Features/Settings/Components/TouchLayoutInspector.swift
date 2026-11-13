//
//  TouchLayoutInspector.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchLayoutInspector: View {
    @Environment(\.dimensions) private var dimensions

    @Bindable var editor: TouchLayoutEditorViewModel

    var body: some View {
        VStack(spacing: dimensions.spaceMedium) {
            if editor.isStickSelected {
                stickVisibility
            }

            LabeledContent {
                Slider(value: $editor.selectedScale, in: editor.scaleRange)
            } label: {
                Text("touchEditor.size")
            }
            .disabled(!editor.canResizeSelection)
        }
        .padding(dimensions.spaceMedium)
        .frame(width: dimensions.touchInspectorWidth)
        .glassEffect(in: .rect(cornerRadius: dimensions.cornerRadiusLarge))
    }

    private var stickVisibility: some View {
        Picker("touchEditor.stick", selection: $editor.selectedStickVisibility) {
            ForEach(TouchStickVisibility.allCases, id: \.self) { visibility in
                Text(visibility.title)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .sensoryFeedback(.selection, trigger: editor.selectedStickVisibility)
    }
}

#if DEBUG
#Preview {
    if let editor = PreviewObjectPool.touchLayoutEditor {
        TouchLayoutInspector(editor: editor)
            .padding()
            .background(.black)
            .environment(\.colorScheme, .dark)
    }
}
#endif

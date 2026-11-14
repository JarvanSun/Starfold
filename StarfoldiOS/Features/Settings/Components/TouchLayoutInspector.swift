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

    @Bindable var touchLayoutEditorViewModel: TouchLayoutEditorViewModel

    var body: some View {
        VStack(spacing: dimensions.spaceMedium) {
            if touchLayoutEditorViewModel.isStickSelected {
                stickVisibility
            }

            LabeledContent {
                Slider(
                    value: $touchLayoutEditorViewModel.selectedScale,
                    in: touchLayoutEditorViewModel.scaleRange
                )
            } label: {
                Text("touchEditor.size")
            }
            .disabled(!touchLayoutEditorViewModel.canResizeSelection)
        }
        .padding(dimensions.spaceMedium)
        .frame(width: dimensions.touchInspectorWidth)
        .glassEffect(in: .rect(cornerRadius: dimensions.cornerRadiusLarge))
    }

    private var stickVisibility: some View {
        Picker("touchEditor.stick", selection: $touchLayoutEditorViewModel.selectedStickVisibility)
        {
            ForEach(TouchStickVisibility.allCases, id: \.self) { visibility in
                Text(visibility.title)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .sensoryFeedback(.selection, trigger: touchLayoutEditorViewModel.selectedStickVisibility)
    }
}

#if DEBUG
#Preview {
    if let touchLayoutEditorViewModel = PreviewObjectPool.touchLayoutEditorViewModel {
        TouchLayoutInspector(touchLayoutEditorViewModel: touchLayoutEditorViewModel)
            .padding()
            .background(.black)
            .environment(\.colorScheme, .dark)
    }
}
#endif

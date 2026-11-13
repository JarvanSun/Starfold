//
//  TouchLayoutEditorPill.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchLayoutEditorPill: View {
    @Environment(\.dimensions) private var dimensions
    @State private var isShowingOpacity = false

    @Bindable var editor: TouchLayoutEditorViewModel

    let selected: TouchControlPlacement?

    var body: some View {
        HStack(spacing: dimensions.spaceXSmall) {
            title
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(minimumTitleScale)
                .padding(.horizontal, dimensions.spaceSmall)

            Button("touchEditor.opacity", systemImage: "circle.lefthalf.filled") {
                isShowingOpacity = true
            }
            .popover(isPresented: $isShowingOpacity) { opacity }

            Button("touchEditor.reset", systemImage: "arrow.counterclockwise") { editor.reset() }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .padding(dimensions.spaceXSmall)
        .padding(.leading, dimensions.spaceXSmall)
        .glassEffect(in: .capsule)
    }

    private var minimumTitleScale: CGFloat {
        0.8
    }

    private var title: Text {
        switch selected {
        case let placement?: Text(placement.input.title)
        case nil: Text("touchEditor.title")
        }
    }

    private var opacity: some View {
        LabeledContent {
            Slider(value: $editor.opacity, in: editor.opacityRange)
                .frame(width: dimensions.touchEditorSliderWidth)
        } label: {
            Text("touchEditor.opacity")
        }
        .padding(dimensions.spaceLarge)
        .presentationCompactAdaptation(.popover)
    }
}

#if DEBUG
#Preview {
    if let editor = PreviewObjectPool.touchLayoutEditor {
        TouchLayoutEditorPill(editor: editor, selected: nil)
            .padding()
            .background(.black)
            .environment(\.colorScheme, .dark)
    }
}
#endif

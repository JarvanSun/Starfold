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
    @State private var resets = 0

    @Bindable var touchLayoutEditorViewModel: TouchLayoutEditorViewModel

    let selected: TouchControlPlacement?

    var body: some View {
        let minimumTitleScale: CGFloat = 0.8

        HStack(spacing: dimensions.spaceXSmall) {
            title
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(minimumTitleScale)
                .padding(.leading, dimensions.spaceLarge)
                .padding(.trailing, dimensions.spaceXSmall)

            iconButton("touchEditor.opacity", systemImage: "circle.lefthalf.filled") {
                isShowingOpacity = true
            }
            .popover(isPresented: $isShowingOpacity) { opacity }

            iconButton("touchEditor.reset", systemImage: "arrow.counterclockwise") { reset() }
        }
        .buttonStyle(.borderless)
        .glassEffect(in: .capsule)
        .sensoryFeedback(.impact(weight: .medium), trigger: resets)
    }

    private func iconButton(
        _ title: LocalizedStringKey,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.title3)
                .frame(
                    width: dimensions.touchEditorButtonSize,
                    height: dimensions.touchEditorButtonSize
                )
                .contentShape(.circle)
        }
    }

    private func reset() {
        touchLayoutEditorViewModel.reset()
        resets += 1
    }

    private var title: Text {
        switch selected {
        case let placement?: Text(placement.input.title)
        case nil: Text("touchEditor.title")
        }
    }

    private var opacity: some View {
        LabeledContent {
            Slider(
                value: $touchLayoutEditorViewModel.opacity,
                in: touchLayoutEditorViewModel.opacityRange
            )
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
    if let touchLayoutEditorViewModel = PreviewObjectPool.touchLayoutEditorViewModel {
        TouchLayoutEditorPill(touchLayoutEditorViewModel: touchLayoutEditorViewModel, selected: nil)
            .padding()
            .background(.black)
            .environment(\.colorScheme, .dark)
    }
}
#endif

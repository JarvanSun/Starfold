//
//  TouchLayoutEditorView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchLayoutEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dimensions) private var dimensions
    @Bindable var editor: TouchLayoutEditorViewModel

    var body: some View {
        ZStack {
            SkyBackground()
                .ignoresSafeArea()
                .onTapGesture { editor.select(nil) }

            GeometryReader { proxy in
                controls(in: proxy.size)
                    .onChange(of: TouchOrientation(size: proxy.size), initial: true) {
                        _,
                        orientation in
                        editor.show(orientation)
                    }
            }

            TouchLayoutEditorPanel(editor: editor) { dismiss() }
                .padding(.top, dimensions.spaceLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .landscapeOnPhone()
        .environment(\.colorScheme, .dark)
    }

    private func controls(in size: CGSize) -> some View {
        let plan = editor.plan(
            for: dimensions.touchMetrics(forVerticalSizeClass: verticalSizeClass)
        )

        return ZStack(alignment: .topLeading) {
            TouchControlsOverlay(
                plan: plan,
                isActive: true,
                isInteractive: false,
                isHapticsEnabled: false,
                onConnect: {}
            )

            ForEach(plan.controls) { placement in
                control(placement)
                    .position(placement.position(in: size))
            }
        }
    }

    private func control(_ placement: TouchControlPlacement) -> some View {
        EditableTouchControl(
            placement: placement,
            isSelected: editor.selectedID == placement.id,
            onMove: { editor.move(placement.id, by: $0) },
            onEndMove: { editor.endMove() },
            onSelect: { editor.select(placement.id) }
        )
    }
}

#if DEBUG
#Preview {
    TouchLayoutEditorView(editor: PreviewObjectPool.settingsViewModel.touchLayoutEditor())
}
#endif

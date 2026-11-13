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
        let plan = editor.plan(
            for: dimensions.touchMetrics(forVerticalSizeClass: verticalSizeClass)
        )
        let selected = plan.controls.first { $0.id == editor.selectedID }

        ZStack {
            SkyBackground()
                .ignoresSafeArea()
                .onTapGesture { editor.select(nil) }

            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    controls(plan, in: proxy.size)

                    if let selected {
                        inspector(beside: selected, in: proxy.size)
                    }
                }
                .onChange(of: TouchOrientation(size: proxy.size), initial: true) {
                    _,
                    orientation in
                    editor.show(orientation)
                }
            }

            TouchLayoutEditorPill(editor: editor, selected: selected)
                .padding(.top, dimensions.spaceLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .opacity(chromeOpacity)
                .animation(.easeOut(duration: fadeDuration), value: editor.isMoving)

            Button(role: .close) {
                dismiss()
            } label: {
                Label("touchEditor.close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .padding(dimensions.spaceLarge)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .landscapeOnPhone()
        .environment(\.colorScheme, .dark)
    }

    private var chromeOpacity: Double {
        editor.isMoving ? 0 : 1
    }

    private var fadeDuration: Double {
        0.15
    }

    private func controls(_ plan: TouchControlPlan, in size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            TouchControlsOverlay(
                plan: plan,
                isActive: true,
                isInteractive: false,
                isHapticsEnabled: false,
                onConnect: {}
            )

            ForEach(plan.controls) { placement in
                control(placement, in: plan)
                    .position(placement.position(in: size))
            }
        }
    }

    private func inspector(beside placement: TouchControlPlacement, in size: CGSize) -> some View {
        BesideLayout(
            anchor: placement.position(in: size),
            clearance: placement.diameter / 2 + dimensions.spaceMedium,
            insets: EdgeInsets(
                top: dimensions.touchInspectorTopInset,
                leading: 0,
                bottom: dimensions.spaceLarge,
                trailing: 0
            )
        ) {
            TouchLayoutInspector(editor: editor)
        }
        .opacity(chromeOpacity)
        .animation(.easeOut(duration: fadeDuration), value: editor.isMoving)
    }

    private func control(_ placement: TouchControlPlacement, in plan: TouchControlPlan) -> some View
    {
        ZStack {
            TouchStickPlaceholder(
                visibility: plan.sticks.visibility(of: placement.input),
                diameter: placement.diameter
            )

            EditableTouchControl(
                placement: placement,
                isSelected: editor.selectedID == placement.id,
                onMove: { editor.move(placement, by: $0) },
                onEndMove: { editor.endMove() },
                onSelect: { editor.select(placement) }
            )
        }
    }
}

#if DEBUG
#Preview {
    if let editor = PreviewObjectPool.touchLayoutEditor {
        TouchLayoutEditorView(editor: editor)
    }
}
#endif

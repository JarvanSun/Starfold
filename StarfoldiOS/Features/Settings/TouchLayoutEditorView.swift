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
    @Bindable var touchLayoutEditorViewModel: TouchLayoutEditorViewModel

    var body: some View {
        ZStack {
            SkyBackground()
                .ignoresSafeArea()
                .onTapGesture { touchLayoutEditorViewModel.select(nil) }

            GeometryReader { proxy in
                editor(in: proxy.size)
            }
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .landscapeOnPhone()
        .environment(\.colorScheme, .dark)
    }

    private func editor(in size: CGSize) -> some View {
        let orientation = TouchOrientation(size: size)
        let plan = touchLayoutEditorViewModel.plan(
            for: dimensions.touchMetrics(forVerticalSizeClass: verticalSizeClass),
            in: orientation
        )
        let selected = touchLayoutEditorViewModel.selectedPlacement(in: plan)

        return ZStack(alignment: .topLeading) {
            controls(plan, in: size)
                .overlay(if: selected, alignment: .topLeading) { inspector(beside: $0, in: size) }
                .onChange(of: orientation, initial: true) { _, orientation in
                    touchLayoutEditorViewModel.show(orientation)
                }

            hiddenWhileMoving(
                TouchLayoutEditorPill(
                    touchLayoutEditorViewModel: touchLayoutEditorViewModel,
                    selected: selected
                )
                .padding(.top, dimensions.spaceLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            )

            closeButton
        }
    }

    private var closeButton: some View {
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

    private func hiddenWhileMoving(_ content: some View) -> some View {
        let fadeDuration = 0.15

        return
            content
            .opacity(touchLayoutEditorViewModel.isMoving ? 0 : 1)
            .animation(.easeOut(duration: fadeDuration), value: touchLayoutEditorViewModel.isMoving)
    }

    private func controls(_ plan: TouchControlPlan, in size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            TouchControlsOverlay(plan: plan, mode: .preview)

            ForEach(plan.controls) { placement in
                control(placement, in: plan)
                    .position(placement.position(in: size))
            }
        }
    }

    private func inspector(beside placement: TouchControlPlacement, in size: CGSize) -> some View {
        hiddenWhileMoving(
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
                TouchLayoutInspector(touchLayoutEditorViewModel: touchLayoutEditorViewModel)
                    .id(placement.id)
            }
        )
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
                isSelected: touchLayoutEditorViewModel.selectedID == placement.id,
                onMove: { touchLayoutEditorViewModel.move(placement, by: $0) },
                onEndMove: { touchLayoutEditorViewModel.endMove() },
                onSelect: { touchLayoutEditorViewModel.select(placement) }
            )
        }
    }
}

#if DEBUG
#Preview {
    if let touchLayoutEditorViewModel = PreviewObjectPool.touchLayoutEditorViewModel {
        TouchLayoutEditorView(touchLayoutEditorViewModel: touchLayoutEditorViewModel)
    }
}
#endif

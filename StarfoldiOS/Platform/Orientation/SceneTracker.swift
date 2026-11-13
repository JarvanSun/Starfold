//
//  SceneTracker.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI
import UIKit

struct SceneTracker: UIViewRepresentable {
    let onAttach: (UIWindowScene) -> Void
    let onDetach: (UIWindowScene) -> Void

    func makeUIView(context: Context) -> SceneTrackingView {
        .init(onAttach: onAttach, onDetach: onDetach)
    }

    func updateUIView(_ view: SceneTrackingView, context: Context) {}
}

final class SceneTrackingView: UIView {
    private let onAttach: (UIWindowScene) -> Void
    private let onDetach: (UIWindowScene) -> Void

    private weak var attachedScene: UIWindowScene?

    init(
        onAttach: @escaping (UIWindowScene) -> Void,
        onDetach: @escaping (UIWindowScene) -> Void
    ) {
        self.onAttach = onAttach
        self.onDetach = onDetach

        super.init(frame: .zero)

        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        switch (window?.windowScene, attachedScene) {
        case (let scene?, _): attach(scene)
        case (nil, let scene?): detach(scene)
        case (nil, nil): break
        }
    }

    private func attach(_ scene: UIWindowScene) {
        attachedScene = scene

        onAttach(scene)
    }

    private func detach(_ scene: UIWindowScene) {
        attachedScene = nil

        onDetach(scene)
    }
}

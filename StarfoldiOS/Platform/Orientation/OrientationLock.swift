//
//  OrientationLock.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Observation
import SwiftUI
import UIKit

@Observable
final class OrientationLock {
    private(set) var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown

    func lockToLandscape(in scene: UIWindowScene) {
        apply(.landscape, in: scene)
    }

    func unlock(in scene: UIWindowScene) {
        apply(.allButUpsideDown, in: scene)
    }

    private func apply(_ orientations: UIInterfaceOrientationMask, in scene: UIWindowScene) {
        supportedOrientations = orientations

        scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()

        scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations)) { _ in }
    }
}

extension View {
    func landscapeOnPhone() -> some View {
        modifier(LandscapeOnPhone())
    }
}

private struct LandscapeOnPhone: ViewModifier {
    @Environment(OrientationLock.self) private var orientation: OrientationLock?

    func body(content: Content) -> some View {
        content
            .background {
                SceneTracker(onAttach: { lock($0) }, onDetach: { unlock($0) })
                    .frame(width: 0, height: 0)
            }
    }

    private var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    private func lock(_ scene: UIWindowScene) {
        guard isPhone else { return }

        orientation?.lockToLandscape(in: scene)
    }

    private func unlock(_ scene: UIWindowScene) {
        guard isPhone else { return }

        orientation?.unlock(in: scene)
    }
}

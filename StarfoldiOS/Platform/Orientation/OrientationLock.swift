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

    private var landscapeHolders = 0

    func holdLandscape() {
        landscapeHolders += 1

        update()
    }

    private func update() {
        let orientations: UIInterfaceOrientationMask =
            landscapeHolders > 0 ? .landscape : .allButUpsideDown
        guard orientations != supportedOrientations else { return }

        supportedOrientations = orientations

        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()

            scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations)) { _ in }
        }
    }

    func releaseLandscape() {
        landscapeHolders = max(0, landscapeHolders - 1)

        update()
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
            .onAppear { hold() }
            .onDisappear { release() }
    }

    private func hold() {
        guard isPhone else { return }

        orientation?.holdLandscape()
    }

    private func release() {
        guard isPhone else { return }

        orientation?.releaseLandscape()
    }

    private var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

//
//  StreamHost.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI
import UIKit

struct StreamHost<Content: View>: UIViewControllerRepresentable {
    let isRawInputEnabled: Bool
    let onRemoteBack: @MainActor @Sendable () -> Void
    let onRemotePlayPause: @MainActor @Sendable () -> Void
    @ViewBuilder let content: () -> Content

    func makeUIViewController(context: Context) -> StreamEventViewController<Content> {
        .init(rootView: content(), onBack: onRemoteBack, onPlayPause: onRemotePlayPause)
    }

    func updateUIViewController(_ controller: StreamEventViewController<Content>, context: Context)
    {
        controller.host.rootView = content()
        controller.onBack = onRemoteBack
        controller.onPlayPause = onRemotePlayPause
        controller.isRawInputEnabled = isRawInputEnabled
    }

    static func dismantleUIViewController(
        _ controller: StreamEventViewController<Content>,
        coordinator: ()
    ) {
        controller.removeRemoteHandlers()
    }
}

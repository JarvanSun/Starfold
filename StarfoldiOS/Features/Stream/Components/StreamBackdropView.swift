//
//  StreamBackdropView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamBackdropView: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let backdrop: StreamBackdrop

    var body: some View {
        switch backdrop {
        case .game(let url): gameArtwork(url)
        case .console: SkyBackground()
        }
    }

    private func gameArtwork(_ url: URL?) -> some View {
        ZStack {
            SkyBackground()

            AsyncImage(url: url, transaction: .init(animation: .easeOut(duration: 0.6))) {
                phase in
                switch phase.image {
                case let image?: blurred(image)
                case nil: EmptyView()
                }
            }
        }
        .clipped()
        .ignoresSafeArea()
    }

    private func blurred(_ image: Image) -> some View {
        image.resizable().scaledToFill()
            .blur(radius: dimensions.streamBackdropBlurRadius, opaque: true)
            .overlay(palette.night.color.opacity(0.55))
            .transition(.opacity)
    }
}

#if DEBUG
#Preview {
    StreamBackdropView(
        backdrop: PreviewObjectPool.cloudStreamViewModel(phase: .connecting).backdrop
    )
    .frame(width: 640, height: 360)
}
#endif

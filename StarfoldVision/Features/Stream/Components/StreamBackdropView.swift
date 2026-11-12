//
//  StreamBackdropView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamBackdropView: View {
    @Environment(\.dimensions) private var dimensions

    let backdrop: StreamBackdrop

    var body: some View {
        switch backdrop {
        case .game(let url): gameArtwork(url)
        case .console: EmptyView()
        }
    }
}

private extension StreamBackdropView {
    var artworkOpacity: Double {
        0.35
    }

    func gameArtwork(_ url: URL?) -> some View {
        AsyncImage(url: url, transaction: .init(animation: .easeOut(duration: 0.6))) { phase in
            switch phase.image {
            case let image?: blurred(image)
            case nil: EmptyView()
            }
        }
    }

    func blurred(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .blur(radius: dimensions.streamBackdropBlurRadius, opaque: true)
            .opacity(artworkOpacity)
            .transition(.opacity)
    }
}

#if DEBUG
#Preview(windowStyle: .plain) {
    StreamBackdropView(
        backdrop: PreviewObjectPool.cloudStreamViewModel(phase: .connecting).backdrop
    )
    .frame(width: 1280, height: 720)
}
#endif

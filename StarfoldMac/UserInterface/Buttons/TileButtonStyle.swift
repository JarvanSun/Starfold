//
//  TileButtonStyle.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct TileButtonStyle: ButtonStyle {
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .hoverLift(isHovering: isHovering)
            .animation(.spring(duration: 0.3, bounce: 0.35), value: isHovering)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
            .onHover { isHovering = $0 }
    }
}

private extension TileButtonStyle {
    var pressedScale: CGFloat {
        0.97
    }
}

#if DEBUG
#Preview {
    Button {
    } label: {
        GameArtwork(url: nil, aspectRatio: 1)
            .frame(width: 112)
    }
    .buttonStyle(.tile)
    .padding()
}
#endif

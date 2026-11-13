//
//  TileButtonStyle.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI

struct TileButtonStyle: ButtonStyle {
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        let pressedScale: CGFloat = 0.97

        return configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .hoverLift(isHovering: isHovering)
            .animation(.spring(duration: 0.3, bounce: 0.35), value: isHovering)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
            .onHover { isHovering = $0 }
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

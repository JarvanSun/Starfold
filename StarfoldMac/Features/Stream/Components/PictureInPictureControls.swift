//
//  PictureInPictureControls.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PictureInPictureControls: View {
    @Environment(\.dimensions) private var dimensions

    let onReturnToWindow: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: dimensions.spaceSmall) {
            Button {
                onReturnToWindow()
            } label: {
                Label(
                    String(localized: "stream.pictureInPicture.backToWindow"),
                    systemImage: "pip.exit"
                )
            }
            .help(Text("stream.pictureInPicture.backToWindow"))

            Button {
                onClose()
            } label: {
                Label(
                    String(localized: "stream.pictureInPicture.disconnect.label"),
                    systemImage: "xmark"
                )
            }
            .help(Text("stream.pictureInPicture.disconnect.tooltip"))
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.glass)
        .environment(\.colorScheme, .dark)
        .padding(dimensions.spaceXXSmall)
    }
}

#if DEBUG
#Preview {
    PictureInPictureControls(onReturnToWindow: {}, onClose: {})
        .padding()
        .background(.black)
}
#endif

//
//  QRCodeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct QRCodeView: View {
    @Environment(\.dimensions) private var dimensions

    let qrCode: QRCode

    var body: some View {
        switch qrCode.image {
        case let image?: picture(image)
        case nil: EmptyView()
        }
    }
}

private extension QRCodeView {
    func picture(_ image: CGImage) -> some View {
        Image(decorative: image, scale: 1)
            .interpolation(.none)
            .resizable()
            .frame(width: dimensions.qrCodeSize, height: dimensions.qrCodeSize)
            .padding(dimensions.spaceMedium)
            .background(.white, in: .rect(cornerRadius: dimensions.cornerRadiusLarge))
    }
}

#if DEBUG
#Preview {
    QRCodeView(qrCode: PreviewObjectPool.signInCode.qrCode)
        .padding()
        .background(Palette(.nebula).night.color)
}
#endif

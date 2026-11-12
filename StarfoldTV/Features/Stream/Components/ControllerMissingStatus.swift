//
//  ControllerMissingStatus.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct ControllerMissingStatus: View {
    let onCheckAgain: () -> Void

    var body: some View {
        MessageView(
            title: "controller.missing.title",
            message: Text("controller.missing.instructions"),
            actionLabel: "controller.missing.checkAgain",
            onAction: onCheckAgain
        )
        .background(.regularMaterial)
    }
}

#if DEBUG
#Preview {
    ControllerMissingStatus {}
}
#endif

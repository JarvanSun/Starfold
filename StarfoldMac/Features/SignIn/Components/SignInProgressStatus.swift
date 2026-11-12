//
//  SignInProgressStatus.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInProgressStatus: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let progress: SignInProgress

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Image(systemName: progress.systemImage)
                .font(.system(size: dimensions.messageSymbolSize))
                .foregroundStyle(symbolStyle)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: progress)

            Text(progress.title)
                .font(.title3.bold())
                .contentTransition(.opacity)
        }
        .frame(minHeight: dimensions.signInStatusMinimumHeight)
    }
}

private extension SignInProgressStatus {
    var symbolStyle: AnyShapeStyle {
        switch progress {
        case .signingIn: .init(palette.primaryFill)
        case .signedIn: .init(Color.online)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        SignInProgressStatus(progress: .signingIn)

        SignInProgressStatus(progress: .signedIn)
    }
    .padding()
    .background(Palette(.nebula).night.color)
    .environment(\.colorScheme, .dark)
}
#endif

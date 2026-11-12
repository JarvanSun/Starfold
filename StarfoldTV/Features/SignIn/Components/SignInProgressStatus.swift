//
//  SignInProgressStatus.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInProgressStatus: View {
    @Environment(\.dimensions) private var dimensions

    let progress: SignInProgress

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            Image(systemName: progress.systemImage)
                .font(.system(size: dimensions.signInStatusSymbolPointSize))
                .foregroundStyle(symbolStyle)
                .contentTransition(.symbolEffect(.replace))

            Text(progress.title).font(.title2.bold())
        }
        .frame(minHeight: dimensions.signInStatusMinimumHeight)
    }
}

private extension SignInProgressStatus {
    var symbolStyle: AnyShapeStyle {
        switch progress {
        case .signingIn: .init(.primary)
        case .signedIn: .init(Color.online)
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        SignInProgressStatus(progress: .signingIn)

        SignInProgressStatus(progress: .signedIn)
    }
}
#endif

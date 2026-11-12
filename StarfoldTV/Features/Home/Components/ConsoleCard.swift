//
//  ConsoleCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ConsoleCard: View {
    let console: Console
    let home: HomeViewModel
    let width: CGFloat

    var body: some View {
        HomeCard(
            title: Text(console.name),
            subtitle: Text(console.modelName),
            status: Text(console.powerStateDescription),
            statusColor: home.status(of: console).color,
            width: width,
            onSelect: play
        ) {
            picture
        }
        .contextMenu { powerButton }
    }
}

private extension ConsoleCard {
    @ViewBuilder
    var picture: some View {
        switch home.cover(for: console) {
        case .game(let url): Artwork(url: url)
        case .lastFrame(let image): Image(decorative: image, scale: 1).resizable().scaledToFill()
        case .placeholder: modelName
        }
    }

    var modelName: some View {
        Text(console.modelName)
            .font(.title2.bold())
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cardFill)
    }

    @ViewBuilder
    var powerButton: some View {
        switch home.powerControl(for: console) {
        case .command(let command): powerButton(for: command)
        case .sending(let command): powerButton(for: command).disabled(true)
        case .unavailable: EmptyView()
        }
    }

    func powerButton(for command: XboxLiveClient.PowerCommand) -> some View {
        Button(action: togglePower) {
            Label(command.title, systemImage: "power")
        }
    }

    func play() {
        home.play(console)
    }

    func togglePower() {
        Task { await home.togglePower(of: console) }
    }
}

#if DEBUG
#Preview {
    let home = PreviewObjectPool.homeViewModel()
    HStack {
        ForEach(PreviewObjectPool.consoles) { console in
            ConsoleCard(console: console, home: home, width: 480)
        }
    }
}
#endif

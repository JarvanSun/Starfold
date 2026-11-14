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
    let homeViewModel: HomeViewModel
    let width: CGFloat

    var body: some View {
        HomeCard(
            title: Text(console.name),
            subtitle: Text(console.modelName),
            status: Text(console.powerStateDescription),
            statusColor: homeViewModel.status(of: console).color,
            width: width,
            onSelect: { play() }
        ) {
            picture
        }
        .contextMenu { powerButton }
    }

    private func play() {
        homeViewModel.play(console)
    }

    @ViewBuilder
    private var picture: some View {
        switch homeViewModel.cover(for: console) {
        case .game(let url): Artwork(url: url)
        case .lastFrame(let image): Image(decorative: image, scale: 1).resizable().scaledToFill()
        case .placeholder: modelName
        }
    }

    private var modelName: some View {
        Text(console.modelName)
            .font(.title2.bold())
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cardFill)
    }

    @ViewBuilder
    private var powerButton: some View {
        switch homeViewModel.powerControl(for: console) {
        case .command(let command): powerButton(for: command)
        case .sending(let command): powerButton(for: command).disabled(true)
        case .unavailable: EmptyView()
        }
    }

    private func powerButton(for command: XboxLiveClient.PowerCommand) -> some View {
        Button {
            togglePower()
        } label: {
            Label(command.title, systemImage: "power")
        }
    }

    private func togglePower() {
        Task { await homeViewModel.togglePower(of: console) }
    }
}

#if DEBUG
#Preview {
    let homeViewModel = PreviewObjectPool.homeViewModel()
    HStack {
        ForEach(PreviewObjectPool.consoles) { console in
            ConsoleCard(console: console, homeViewModel: homeViewModel, width: 480)
        }
    }
}
#endif

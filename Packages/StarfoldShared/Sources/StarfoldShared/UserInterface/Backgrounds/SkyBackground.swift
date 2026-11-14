//
//  SkyBackground.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/30.
//

import SwiftUI

public struct SkyBackground: View {
    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.skyCanvasSize) private var canvasSize
    #if os(macOS)
    @Environment(\.controlActiveState) private var activeState
    #endif
    @State private var start = Date.now

    public init() {}

    public var body: some View {
        canvas
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var canvas: some View {
        switch canvasSize {
        case let size?:
            Color.clear
                .overlay(alignment: .top) {
                    animatedSky.frame(width: size.width, height: size.height)
                }
        case nil: animatedSky
        }
    }

    private var animatedSky: some View {
        let frameInterval: Double = 1 / 30

        return TimelineView(.animation(minimumInterval: frameInterval, paused: isPaused)) {
            context in
            GeometryReader { proxy in
                Rectangle()
                    .colorEffect(sky(size: proxy.size, time: shaderTime(at: context.date)))
            }
        }
    }

    private func sky(size: CGSize, time: Float) -> Shader {
        let sky = palette.sky
        return ShaderLibrary.bundle(.module).paletteSky(
            .float2(size),
            .float(time),
            sky.top.shaderArgument,
            sky.bottom.shaderArgument,
            sky.glow.tint.shaderArgument,
            .float(sky.glow.strength),
            sky.ribbons.first.shaderArgument,
            sky.ribbons.second.shaderArgument,
            sky.ribbons.third.shaderArgument,
            .float(sky.ribbons.strength)
        )
    }

    private func shaderTime(at date: Date) -> Float {
        let stillFrameTime: Float = 12

        return reduceMotion ? stillFrameTime : Float(date.timeIntervalSince(start))
    }

    private var isPaused: Bool {
        #if os(macOS)
        reduceMotion || activeState == .inactive
        #else
        reduceMotion
        #endif
    }
}

private extension RGBColor {
    var shaderArgument: Shader.Argument {
        .float3(Float(red), Float(green), Float(blue))
    }
}

#if DEBUG
#Preview("Palettes") {
    VStack(spacing: 0) {
        ForEach(PaletteID.allCases, id: \.self) { id in
            SkyBackground()
                .frame(width: 900, height: 600)
                .palette(Palette(id))
        }
    }
}
#endif

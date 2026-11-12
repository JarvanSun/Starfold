//
//  SkyBackground.metal
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/28.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float ribbon(float2 uv, float time, float baseline, float amplitude, float frequency,
                    float speed, float phase, float thickness) {
    float wave = baseline
        + amplitude * sin(uv.x * frequency + time * speed + phase)
        + amplitude * 0.45 * sin(uv.x * frequency * 2.3 - time * speed * 0.7 + phase * 1.7);
    float distance = abs(uv.y - wave);
    return smoothstep(thickness, 0.0, distance) * 0.55 + exp(-distance * 28.0) * 0.45;
}

[[ stitchable ]] half4 paletteSky(float2 position, half4 color, float2 size, float time,
                                  float3 top, float3 bottom, float3 glow, float glowStrength,
                                  float3 ribbon1, float3 ribbon2, float3 ribbon3, float ribbonStrength) {
    float2 uv = position / size;
    float aspect = size.x / max(size.y, 1.0);

    float3 sky = mix(top, bottom, smoothstep(0.0, 1.0, uv.y));

    float2 sunCenter = float2(0.82, 1.05);
    float2 delta = (uv - sunCenter) * float2(aspect, 1.0);
    float sun = exp(-length(delta) * 2.6) * (0.85 + 0.15 * sin(time * 0.35));
    sky += glow * sun * glowStrength;

    float x = uv.x * aspect;
    float r1 = ribbon(float2(x, uv.y), time, 0.74, 0.050, 1.6, 0.22, 0.0, 0.020);
    float r2 = ribbon(float2(x, uv.y), time, 0.81, 0.040, 2.1, -0.17, 2.1, 0.014);
    float r3 = ribbon(float2(x, uv.y), time, 0.88, 0.035, 2.7, 0.12, 4.2, 0.010);
    float3 tint1 = mix(ribbon1, ribbon2, uv.x);
    float3 tint2 = mix(ribbon2, ribbon3, uv.x);
    float3 tint3 = mix(ribbon3, ribbon1, uv.x);
    float3 light = (tint1 * r1 * 0.55 + tint2 * r2 * 0.40 + tint3 * r3 * 0.30) * ribbonStrength;

    float edge = smoothstep(0.0, 0.18, uv.x) * smoothstep(1.0, 0.82, uv.x);
    sky += light * mix(0.35, 1.0, edge);

    float grain = fract(sin(dot(position, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    sky += grain * 0.012;

    return half4(half3(sky), 1.0);
}

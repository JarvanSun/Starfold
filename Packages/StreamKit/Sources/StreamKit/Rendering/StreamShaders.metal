//
//  StreamShaders.metal
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut streamVertex(uint vid [[vertex_id]]) {
    float2 positions[3] = { float2(-1, -1), float2(3, -1), float2(-1, 3) };
    VertexOut out;
    out.position = float4(positions[vid], 0, 1);
    out.uv = float2((positions[vid].x + 1) * 0.5, 1 - (positions[vid].y + 1) * 0.5);
    return out;
}

struct ColorConversion {
    float3x3 matrix;
    float3 offset;
};

fragment float4 streamYUVFragment(VertexOut in [[stage_in]],
                                  texture2d<float> luma [[texture(0)]],
                                  texture2d<float> chroma [[texture(1)]],
                                  constant ColorConversion &conversion [[buffer(0)]]) {
    constexpr sampler linearSampler(filter::linear, address::clamp_to_edge);
    float y = luma.sample(linearSampler, in.uv).r;
    float2 cbcr = chroma.sample(linearSampler, in.uv).rg;
    float3 rgb = conversion.matrix * (float3(y, cbcr) - conversion.offset);
    return float4(saturate(rgb), 1);
}

fragment float4 streamRGBFragment(VertexOut in [[stage_in]],
                                  texture2d<float> source [[texture(0)]]) {
    constexpr sampler linearSampler(filter::linear, address::clamp_to_edge);
    return float4(source.sample(linearSampler, in.uv).rgb, 1);
}

fragment float4 streamToneMapPQFragment(VertexOut in [[stage_in]],
                                        texture2d<float> source [[texture(0)]]) {
    constexpr sampler linearSampler(filter::linear, address::clamp_to_edge);
    float3 linear = pow(saturate(source.sample(linearSampler, in.uv).rgb), 2.4);
    float luminance = dot(linear, float3(0.2126, 0.7152, 0.0722));
    float highlight = smoothstep(0.6, 1.0, luminance);
    float3 nits = linear * 203.0 * (1.0 + (600.0 / 203.0 - 1.0) * highlight * highlight);
    const float3x3 toBT2020 = float3x3(float3(0.6274, 0.0691, 0.0164),
                                       float3(0.3293, 0.9195, 0.0880),
                                       float3(0.0433, 0.0114, 0.8956));
    float3 normalized = max(toBT2020 * nits / 10000.0, 0.0);
    const float m1 = 0.1593017578125, m2 = 78.84375, c1 = 0.8359375, c2 = 18.8515625, c3 = 18.6875;
    float3 p = pow(normalized, m1);
    return float4(pow((c1 + c2 * p) / (1.0 + c3 * p), m2), 1);
}

kernel void streamSharpen(texture2d<float, access::read> source [[texture(0)]],
                          texture2d<float, access::write> destination [[texture(1)]],
                          constant float &strength [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]]) {
    uint width = source.get_width();
    uint height = source.get_height();
    if (gid.x >= width || gid.y >= height) {
        return;
    }
    uint2 maxCoord = uint2(width - 1, height - 1);
    float3 center = source.read(gid).rgb;
    float3 north = source.read(uint2(gid.x, gid.y > 0 ? gid.y - 1 : 0)).rgb;
    float3 south = source.read(min(uint2(gid.x, gid.y + 1), maxCoord)).rgb;
    float3 west = source.read(uint2(gid.x > 0 ? gid.x - 1 : 0, gid.y)).rgb;
    float3 east = source.read(min(uint2(gid.x + 1, gid.y), maxCoord)).rgb;

    float3 minRGB = min(center, min(min(north, south), min(west, east)));
    float3 maxRGB = max(center, max(max(north, south), max(west, east)));
    float3 amplitude = saturate(min(minRGB, 1.0 - maxRGB) / max(maxRGB, 1e-4));
    amplitude = sqrt(amplitude);
    float3 weight = amplitude * -mix(0.125, 0.2, saturate(strength));
    float3 sharpened = (center + (north + south + west + east) * weight) / (1.0 + 4.0 * weight);
    destination.write(float4(saturate(sharpened), 1), gid);
}

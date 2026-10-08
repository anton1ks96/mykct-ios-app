//
//  RibbonWave.metal
//  college-ios-app
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] float2 ribbonWave(float2 position, float2 size, float time) {
    float2 uv = position / size;
    float2 center = float2(0.50, 0.27);
    float2 radius = float2(0.36, 0.23);
    float strength = smoothstep(1.0, 1.4, length((uv - center) / radius));

    float dx = sin(uv.y * 7.0 + time * 0.55) * 6.0
             + sin(uv.y * 15.0 - time * 0.9 + uv.x * 3.0) * 2.5;
    float dy = sin(uv.x * 6.0 - time * 0.45) * 7.0
             + sin(uv.x * 13.0 + time * 0.8 + uv.y * 4.0) * 2.5;

    return position + float2(dx, dy) * strength;
}

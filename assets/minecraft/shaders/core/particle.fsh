#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;

out vec4 fragColor;

in vec3 cornerUV1;
in vec3 cornerUV2;
in vec3 cornerUV3;

const float POWER = 1E-10;
const vec4 MARKER = vec4(0.0471, 0.0431, 0.0392, 0.0353);

vec3 HSLtoRGB(in vec3 hsl) {
    vec3 rawRGB = abs(hsl.x * 6 - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
    vec3 RGB = clamp(rawRGB, 0, 1);
    float c = (1 - abs(2 * hsl.z - 1)) * hsl.y;
    return (RGB - 0.5) * c + hsl.z;
}
vec3 RGBtoHSL(in vec3 RGB) {
    vec4 p = (RGB.g < RGB.b) ? vec4(RGB.bg, -1, 2 / 3) : vec4(RGB.gb, 0, -1 / 3);
    vec4 q = (RGB.r < p.x) ? vec4(p.xyw, RGB.r) : vec4(RGB.r, p.yzx);
    float c = q.x - min(q.w, q.y);
    float h = abs((q.w - q.y) / (6 * c + POWER) + q.z);
    vec3 hcv = vec3(h, c, q.x);
    float z = hcv.z - hcv.y * 0.5;
    float s = hcv.y / (1 - abs(z * 2 - 1) + POWER);
    return vec3(hcv.x, s, z);
}
bool almostEquals(vec4 color, vec4 target) {
    return all(lessThan(abs(color - target), vec4(0.0001)));
}

void main() {
    vec2 cornerUV1 = cornerUV1.xy / cornerUV1.z;
    vec2 cornerUV2 = cornerUV2.xy / cornerUV2.z;
    vec2 cornerUV3 = cornerUV3.xy / cornerUV3.z;
    vec2 minUV = min(cornerUV1, min(cornerUV2, cornerUV3));
    vec2 maxUV = max(cornerUV1, max(cornerUV2, cornerUV3));
    if (almostEquals(texture(Sampler0, minUV + 0.001), MARKER) || almostEquals(texture(Sampler0, maxUV - 0.001), MARKER) ) {
        // animated smoke particles
        vec4 textureColor = texture(Sampler0, texCoord0);
        vec3 HSLColor = RGBtoHSL(textureColor.rgb);
        float opacities = vertexColor.a * vertexColor.a * vertexColor.a;
        opacities += 0.1;
        opacities *= 1.3;
        HSLColor.g *= clamp(opacities, 0, 1);
        vec4 finalColor = vec4(HSLtoRGB(HSLColor), textureColor.a);
        if (finalColor.a < 0.1) {
            discard;
        }
        fragColor = finalColor * vec4(vertexColor.rgb, clamp(vertexColor.a * 9, 0, 1) - 0.15 ) * ColorModulator;
    } else {
        // custom particles
        vec4 color = texture(Sampler0, texCoord0);
        float opacity = color.a;
        if (color.rgb == vec3(1, 1, 1) && opacity == 26.0 / 255.0) {
            discard;
        }
        if (opacity == 179.0 / 255.0) {
            color.a = 1;
        }
        color *= vertexColor * ColorModulator;
        if (opacity < 0.1) {
            discard;
        }
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    }
}

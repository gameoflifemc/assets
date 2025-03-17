#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

#ifdef TRANSLUCENT
uniform float GameTime;
flat in int blinking;
#endif

void main() {
    vec4 color = texture(Sampler0, texCoord0);
#ifdef TRANSLUCENT
    if (blinking == 1 && (texCoord0.y > 0.125 && texCoord0.y < 0.25) && ((texCoord0.x > 0.125 && texCoord0.x < 0.25) || (texCoord0.x > 0.625 && texCoord0.x < 0.75))) {
        vec2 texSize = textureSize(Sampler0, 0);
        color = (mod(GameTime * 1200, 5 + 0.25) < 0.25) ? texture(Sampler0, texCoord0 + vec2(16.0 / texSize.x, -8.0 / texSize.y)) : color;
    }
#endif
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    color *= vertexColor * ColorModulator;
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= lightMapColor;
#endif
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

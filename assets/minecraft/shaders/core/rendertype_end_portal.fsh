#version 150

#moj_import <minecraft:matrix.glsl>

uniform sampler2D Sampler1;

uniform float GameTime;
uniform vec2 ScreenSize;

const vec3[] COLORS = vec3[](
  vec3(0, 0.00392, 0.01176),
  vec3(0, 0.01176, 0.01961),
  vec3(0, 0.01961, 0.03922),
  vec3(0, 0.03922, 0.07843),
  vec3(0.03922, 0.05882, 0.11765),
  vec3(0.07843, 0.07843, 0.16078),
  vec3(0.11765, 0.10196, 0.2),
  vec3(0.15686, 0.12157, 0.24314),
  vec3(0.19608, 0.1451, 0.28627),
  vec3(0.23529, 0.16471, 0.32549),
  vec3(0.27451, 0.18824, 0.36863),
  vec3(0.31373, 0.20784, 0.40784),
  vec3(0.35294, 0.23137, 0.45098),
  vec3(0.39216, 0.25098, 0.49412),
  vec3(0.43137, 0.27451, 0.53333),
  vec3(0.47059, 0.29412, 0.57647),
  vec3(0.51373, 0.31765, 0.61961),
  vec3(0.61176, 0.39216, 0.74118),
  vec3(0.72157, 0.54118, 0.83137)
);

const mat4 SCALE_TRANSLATE = mat4(
    0.5, 0.0, 0.0, 0.25,
    0.0, 0.5, 0.0, 0.25,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
);

mat4 end_portal_layer(float layer) {
    mat4 translate = mat4(
        1.0, 0.0, 0.0, 17.0 / layer,
        0.0, 1.0, 0.0, (2.0 + layer / 1.5) * (GameTime * 3.5),
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
    mat2 rotate = mat2_rotate_z(radians((layer * layer * 4321.0 + layer * 9.0) * 2.0));
    mat2 scale = mat2(mix(12, 0.7, (layer / 20.0)));
    return mat4(rotate * scale) * translate * SCALE_TRANSLATE;
}

out vec4 fragColor;

void main() {
    vec2 texCoord = (gl_FragCoord.xy / ScreenSize) * vec2(ScreenSize.x / ScreenSize.y, 1);
    vec4 stars = vec4(0.051, 0.0078, 0.0471, 1);
    for (int i = 0; i < 20; i++) {
        vec4 star = texture(Sampler1, ( vec4(texCoord, 1, 1) * end_portal_layer(i + 1) ).xy);
        stars += star * star.aaaa * vec4(COLORS[ clamp(i, 0, COLORS.length() - 1 ) ], 1);
    }
    fragColor = stars;
}

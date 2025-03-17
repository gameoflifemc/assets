#version 150

#moj_import <colors.glsl>

in vec4 vertexColor;

uniform vec4 ColorModulator;

out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    float opacity = color.a;
    if (opacity == 0.0) {
        discard;
    }
    color = vec4(BRAND_COLOR, opacity);
    fragColor = color * ColorModulator;
}

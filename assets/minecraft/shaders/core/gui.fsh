#version 150

#moj_import <colors.glsl>

in vec4 vertexColor;
in float depth;

uniform vec4 ColorModulator;

out vec4 fragColor;

void main() {
    // vanilla
    vec4 color = vertexColor;
    float opacity = color.a;
    if (opacity == 0.0) {
        discard;
    }
    vec3 rgb = color.rgb;
    // convert white to signature color
    if (rgb == vec3(1)) {
        if (depth == 2800.0 || opacity == 0.1254902) {
            color = vec4(BRAND_SHADOW, 0.5);
        } else {
            color = vec4(BRAND_COLOR, opacity);
        }
    } else if (rgb == vec3(0)) {
        if (depth == 2800.0 || depth == 2600.0) {
            color = vec4(0);
        }
    } else if (rgb == vec3(208.0 / 255)) {
        color = vec4(BRAND_COLOR, 0.5);
    }
    fragColor = color * ColorModulator;
}

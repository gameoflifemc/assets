#version 150

#moj_import <colors.glsl>

in vec4 vertexColor;
in vec2 texCoord0;

uniform sampler2D Sampler0;
uniform vec4 ColorModulator;
uniform float GameTime;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = color * ColorModulator;
    if (color.r == 0.0, color.g == 0.0) {
        if (color.b == 0.0) {
            discard;
        } else {
            float time = fract(GameTime * 450);
            float c = color.b;
            if (time < 0.25) {
                c += time * 4;
            }
            if (c > 1.0) {
                c -= 1.0;
            }
            fragColor = vec4(vec3(c), 1.0);
        }
    }
}

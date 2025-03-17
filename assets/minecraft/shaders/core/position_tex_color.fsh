#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec2 texCoord0;
in vec4 vertexColor;

out vec4 fragColor;

in float depth;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    float r = color.r;
    float g = color.g;
    float b = color.b;
    // remove empty player heads from TAB list
    if (depth == 2800.0 && r >= 0.332 && r <= 0.334 && g >= 0.332 && g <= 0.334 && b >= 0.332 && b <= 0.334) {
        color = vec4(0);
    }
    fragColor = color * ColorModulator;
}

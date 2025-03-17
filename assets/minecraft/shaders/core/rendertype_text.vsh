#version 150

#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

uniform float GameTime;
out float depth;

void main() {
    depth = Position.z;
    vec4 addend;
    if (depth == 2400.06) {
        float movement = fract(GameTime * 60.0) / 4;
        addend = vec4(0.0, movement, 0.0, 0.0);
    } else {
        addend = vec4(0.0);
    }
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0) + addend;
    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
}

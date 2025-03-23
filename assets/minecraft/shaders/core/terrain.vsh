#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:fade.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ModelOffset;
uniform int FogShape;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

#define FADEPI 3.141592653589793238
#define HALFPI 1.570796326794896619

float rollRandom(vec3 seed) {
    return fract(sin(dot(seed.xyz, vec3(12.9898,78.233,144.7272))) * 43758.5453);
}

mat3 rotationMatrix(vec3 axis, float angle) {
    vec3 normalAxis = normalize(axis);
    float sine = sin(angle);
    float cosine = cos(angle);
    float negCos = 1.0 - cosine;
    float axisX = normalAxis.x;
    float axisY = normalAxis.y;
    float axisZ = normalAxis.z;
    return mat3(
        negCos * axisX * axisX + cosine,       negCos * axisX * axisY - axisZ * sine, negCos * axisZ * axisX + axisY * sine,
        negCos * axisX * axisY + axisZ * sine, negCos * axisY * axisY + cosine,       negCos * axisY * axisZ - axisX * sine,
        negCos * axisZ * axisX - axisY * sine, negCos * axisY * axisZ + axisX * sine, negCos * axisZ * axisZ + cosine
    );
}

void main() {
    // wavy logic
    float xs = 0.0;
    float ys = 0.0;
    float zs = 0.0;
	// If pi is defined, it is something that we care about waving.
#ifdef PI
	// Common variable declaration
	vec3 position = Position / 2.0 * PI;
    float animation = GameTime * 4000.0;
	float alpha = texture(Sampler0, UV0).a * 255.0;
    float m0 = distance(Position.xz, vec2(8.0, 8.0)) * 10.0;
	// From here, we check which wavy logic we should be using
	// Cutout is plants
#ifdef CUTOUT
    if (alpha == 1.0 || alpha == 253.0) { // Most plants like grass and flowers use this
        xs = sin(position.x + animation);
        zs = cos(position.z + position.y + animation);
    } else if (alpha == 2.0) { // Used for the edges of multi-blocks, like the top block of tall grass or the bottom block of twisting vines
        xs = sin(position.x + position.y + animation) * 2.0;
        zs = cos(position.z + position.y + animation) * 2.0;
    } else if (alpha == 3.0) { // Used for spore blossoms' special animation
        xs = sin(position.x + position.y + animation);
        zs = cos(position.z + position.y + animation);
        ys = sin(position.y + (animation / 1.5)) / 9.0;
	} else if (alpha == 4.0) { // Used for vines when Wavy Leaves is enabled
        xs = sin(position.x + (position.y / 2.0) + animation);
        zs = cos(position.z + (position.y / 2.0) + animation);
    } else if (alpha == 5.0) { // Used for lily pads when Wavy Water is enabled
        xs = sin(position.x + animation) * cos(GameTime * 300);
        ys = cos(m0 + animation) * 0.65;
        zs = cos(position.z + animation) * sin(GameTime * 300);
    }
#endif
	// Cutout Mipped is leaves
#ifdef CUTOUT_MIPPED
    if (alpha == 1.0 || alpha == 2.0 || alpha == 253.0) {
        xs = sin(position.x + (position.y / 2.0) + animation);
        zs = cos(position.z + (position.y / 2.0) + animation);
    }
    if (alpha == 2.0) {
        xs *= 2.0;
        zs *= 2.0;
    }
#endif
	// Translucent is water
#ifdef TRANSLUCENT
    if (Color.r < Color.b) {
        xs = sin(position.x + animation) * cos(GameTime * 300);
        ys = cos(m0 + animation) * 0.65;
        zs = cos(position.z + animation) * sin(GameTime * 300);
    }
#endif
#endif
    mat4 matrices = ProjMat * ModelViewMat;
    // vanilla calculations
    vec3 pos = Position + ModelOffset;
    gl_Position = matrices * (vec4(pos, 1.0) + vec4(xs / 32.0, ys / 24.0, zs / 32.0, 0.0));
    vertexDistance = fog_distance(pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    // fade logic
    vec3 absNormal = abs(Normal);
    int PosNegX = 0;
    int PosNegY = 0;
    int NegZ = 0;
    if (absNormal == vec3(1.0, 0.0, 0.0)) {
        PosNegX = 1;
    } else if (absNormal == vec3(0.0, 1.0, 0.0)) {
        PosNegY = 1;
    } else if (Normal == vec3(0.0, 0.0, -1.0)) {
        NegZ = 1;
    }
    vec3 fractPos = Position; // positive Z
    if (PosNegX == 1) { // positive / negative X
        fractPos *= rotationMatrix(Normal.zxy, -HALFPI); // rotate around Y axis
    } else if (PosNegY == 1) { // positive / negative Y
        fractPos *= rotationMatrix(Normal.yzx, HALFPI); // rotate around X axis
    } else if (NegZ == 1) { // negative Y
        fractPos *= rotationMatrix(Normal.yzx, -FADEPI); // rotate around Y axis
    }
    fractPos = fract(fractPos);
    float fractPosX = fractPos.x;
    float fractPosY = fractPos.y;
    // calculate offset
    vec3 offset = vec3(0.5, 0.5, 0.0);
    float offsetX = offset.x;
    float offsetY = offset.y;
    // apply offsetting for fractional positions
    if (fractPosX > 0.001 && fractPosX < 0.999) {
        offset.x = 0.5 - fractPosX;
    }
    if (fractPosY > 0.001 && fractPosY < 0.999) {
        offset.y = 0.5 - fractPosY;
    }
    float vertexId = mod(gl_VertexID, 4.0);
    // correct offsetting for integer positions
    if (vertexId == 0.0 && offsetY == 0.5) {
        offset.y *= -1.0;
    } else if (vertexId == 2.0 && offsetX == 0.5) {
        offset.x *= -1.0;
    } else if (vertexId == 3.0) {
        if (offsetX == 0.5) {
            offset.x *= -1.0;
        }
        if (offsetY == 0.5) {
            offset.y *= -1.0;
        }
    }
    // rotate back to original direction
    if (PosNegX == 1) { // positive / negative X
        offset *= rotationMatrix(Normal.zxy, HALFPI);
    } else if (PosNegY == 1) { // positive / negative Y
        offset *= rotationMatrix(Normal.yzx, -HALFPI);
    } else if (NegZ == 1) { // negative Z
        offset *= rotationMatrix(Normal.yzx, FADEPI);
    }
    float fade = max(0.0, length((ModelViewMat * vec4(pos + offset, 1.0)).xyz) - FADEDISTANCE);
    fade *= fade;

    // apply fade color
    if (fade > 0) {
        vertexColor = vec4((fade + 30) / 75 * FADECOLOR, 1.0);
        float random = rollRandom((Position + offset) / 100.0);
        float anim = (sin(mod((random) * 1600.0, TWOPI)) / 8.0) * 0.25;
        gl_Position = matrices * vec4(pos + offset * clamp(fade * (anim + 0.75) * 0.1 / FADESCALE, 0.0, 1.0), 1.0) + matrices * vec4(Normal, 0.0) * fade * (0.2 / FADESCALE * random + anim * 0.04);
    }
    if (fade > 15.0 * FADESCALE) {
        gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
    }
}

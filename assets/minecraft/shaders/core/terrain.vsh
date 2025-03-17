#version 150

#moj_import <light.glsl>
#moj_import <fade.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ModelOffset;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

#define PI 3.141592653589793238
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
    // vanilla calculations
    vec3 pos = Position + ModelOffset;
    vertexDistance = length((ModelViewMat * vec4(pos, 1.0)).xyz);
    texCoord0 = UV0;

    // combine matrices
    mat4 matrices = ProjMat * ModelViewMat;

    // transform normal
    vec4 normal = matrices * vec4(Normal, 0.0);
    
    // boolean checks
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

    // vertex id
    float vertexId = mod(gl_VertexID, 4.0);

    // fractional position
    vec3 fractPos = Position; // positive Z
    if (PosNegX == 1) { // positive / negative X
        fractPos *= rotationMatrix(Normal.zxy, -HALFPI); // rotate around Y axis
    } else if (PosNegY == 1) { // positive / negative Y
        fractPos *= rotationMatrix(Normal.yzx, HALFPI); // rotate around X axis
    } else if (NegZ == 1) { // negative Y
        fractPos *= rotationMatrix(Normal.yzx, -PI); // rotate around Y axis
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
        offset *= rotationMatrix(Normal.yzx, PI);
    }

    // sync random and fade amount between vertices on same face
    float random = rollRandom((Position + offset) / 100.0);
    float fade = max(0.0, length((ModelViewMat * vec4(pos + offset, 1.0)).xyz) - FADEDISTANCE);
    fade *= fade;
    
    // animation and scaling
    float anim = (sin(mod((random) * 1600.0, TWOPI)) / 8.0) * 0.25;
    float scale = clamp(fade * (anim + 0.75) * 0.1 / FADESCALE, 0.0, 1.0);

    // position with scaling
    gl_Position = matrices * vec4(pos + offset * scale, 1.0);
    // position with offset
    gl_Position += normal * fade * (0.2 / FADESCALE * random + anim * 0.04);

    // apply fade color
    if (fade > 0) {
        vertexColor = vec4((fade + 30) / 75 * FADECOLOR, 1.0);
    } else {
        vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    }

    // disable visibility when out of range
    if (fade > 15.0 * FADESCALE) {
        gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
    }
}

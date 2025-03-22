#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:fade.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 TextureMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;

#ifdef TRANSLUCENT
#moj_import <minecraft:colors.glsl>
uniform sampler2D Sampler0;
flat out int blinking;
#endif

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexDistance = fog_distance(Position, FogShape);
#ifdef NO_CARDINAL_LIGHTING
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif
#ifdef TRANSLUCENT
    vec4 dataPixel = texture(Sampler0, vec2(0.0, 0.0));
    blinking = 0;
    if (dataPixel.a == 1 && dataPixel.rgb == vec3(0.6, 0.26666667, 1)) {
        blinking = 1;
    }
#endif
    // fade
    float fade = max(0.0, vertexDistance - FADEDISTANCE);
    fade *= fade;
    // animation and scaling
    float anim = (sin(mod(1600.0, TWOPI)) / 8.0) * 0.25;
    float scale = clamp(fade * (anim + 0.75) * 0.1 / FADESCALE, 0.0, 1.0);
    // skip inventory items
    if (ProjMat[3][2] / (ProjMat[2][2] + 1) >= 0.0) {
        // position with offset
        gl_Position += ProjMat * ModelViewMat * vec4(Normal, 0.0) * fade * (0.1 / FADESCALE + anim * 0.04);
        // disable visibility when out of range
        if (fade > 15.0 * FADESCALE) {
            gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
        }
        // apply fade color
        if (fade > 0) {
            vertexColor = vec4((fade + 30) / 75 * FADECOLOR, 1.0);
        }
    }
}

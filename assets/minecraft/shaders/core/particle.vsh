#version 150

#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec2 texCoord0;
out vec4 vertexColor;

uniform sampler2D Sampler0;
out vec3 cornerUV1;
out vec3 cornerUV2;
out vec3 cornerUV3;

void main() {
	// vanilla
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexDistance = fog_distance(Position, FogShape);
    texCoord0 = UV0;
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    // animated smoke particles
    int id = gl_VertexID % 4;
    cornerUV1 = cornerUV2 = cornerUV3 = vec3(0);
    switch (id) {
        case 0: {
			cornerUV1 = vec3(UV0.xy, 1);
			break;
		}
        case 1: {
			cornerUV2 = vec3(UV0.xy, 1);
			break;
		}
        case 2: {
			cornerUV3 = vec3(UV0.xy, 1);
			break;
		}
    }
    // custom particles
	int gridSize = 16;
	vec2 texSize = textureSize(Sampler0, 0);
	vec2 texCoordNoOffset = UV0 * texSize;
	texCoordNoOffset.x = texCoordNoOffset.x - mod(texCoordNoOffset.x, gridSize);
	texCoordNoOffset.y = texCoordNoOffset.y - mod(texCoordNoOffset.y, gridSize);
	vec4 cornerColor = texture(Sampler0, (texCoordNoOffset + 0.5) / texSize);
	if (cornerColor.a == 179.0 / 255.0 || cornerColor.a == 26.0 / 255.0) {
		switch (id) {
			case 0: {
                texCoordNoOffset = texCoordNoOffset + gridSize;
                break;
            }
			case 1: {
                texCoordNoOffset.x = texCoordNoOffset.x + gridSize;
                break;
            }
			case 3: {
                texCoordNoOffset.y = texCoordNoOffset.y + gridSize;
                break;
            }
		}
		texCoord0 = texCoordNoOffset / texSize;
	}
}

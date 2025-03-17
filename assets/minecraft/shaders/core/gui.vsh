#version 150

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

void main() {
    // vanilla
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexColor = Color;
    // custom
    float depth = Position.z;
    float opacity = vertexColor.a;
    if (vertexColor.rgb == vec3(0)) {
        if (depth == 2000) {
            // remove scoreboard background
            if (opacity == 0.2980392426 || opacity == 0.4) {
                vertexColor.a = 0;
            }
        } else if (depth == 200 && opacity > 0) {
            // strengthen advancement blur
            vertexColor.a += 0.25;
        } else if (depth == 2800 && opacity == 0.5019608438) {
            vertexColor.a = 0;
        }
    }
}

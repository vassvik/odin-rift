#version 450 core

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;

uniform float time;
uniform mat4 MVP;
uniform vec3 sphere_pos;
uniform vec3 scale;

out vec3 pos;
out vec3 normal;

out vec2 TexCoords;
out vec3 WorldPos;
out vec3 Normal;

void main() {
    gl_Position = MVP*vec4(10.0*(vertexPosition*scale + sphere_pos), 1.0);
    WorldPos = 10.0*(vertexPosition*scale + sphere_pos);
    Normal = vertexNormal;
    TexCoords = vec2(0.0, 0.0);
}
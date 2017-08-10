#version 330 core

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;
layout(location = 2) in vec2 vertexUV;

uniform float time;

uniform vec3 d_model; // offset before rotation
uniform vec3 p_model; // offset after rotation
uniform vec4 q_model; // normalized, rotation quaternion

uniform vec3 p_hmd;
uniform vec4 q_hmd;

uniform mat4 P; // perspective projection matrix, per-eye

out vec2 TexCoords;
out vec3 WorldPos;
out vec3 Normal;

vec3 qrot(vec3 p, vec4 q)
{ 
    // http://www.geeks3d.com/20141201/how-to-rotate-a-vertex-by-a-quaternion-in-glsl/
    return p + 2.0 * cross(q.xyz, cross(q.xyz, p) + q.w * p);
}

vec4 qconj(vec4 q)
{ 
    return vec4(-q.xyz, q.w); 
}

void main()
{
    // passthrough to fragment shader
    TexCoords = vertexUV;
    Normal = qrot(vertexNormal, q_model);

    // input, offset to center model
    vec3 v = vertexPosition + d_model;
    
    // model to world space (i.e. controller models)
    v = qrot(v, q_model) + p_model;

    WorldPos = v;

    // world space to camera space,
    v = qrot(v - p_hmd, qconj(q_hmd));

    // output, view space to clip space
    gl_Position = P*vec4(v, 1.0);
}

#version 330 core

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;
layout(location = 2) in vec2 vertexUV;

uniform float time;

uniform vec3 d_pivot; // offset before rotation
uniform vec4 q_pivot;

uniform vec3 d_model; // offset before rotation
uniform vec3 p_model; // offset after rotation
uniform vec4 q_model; // normalized, rotation quaternion

uniform vec3 p_hmd;
uniform vec4 q_hmd;

uniform mat4 P; // perspective projection matrix, per-eye

out vec2 TexCoords;
out vec3 WorldPos;
out vec3 Normal;

uniform int vertex_mode;
uniform int apply_texture;

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
    vec3 v = vertexPosition;

    if (apply_texture == 2) {
        float y = gl_VertexID % 2;
        float x = gl_VertexID / 2;
        x = x / 8.0;
        y = 2.0*(y / 1.0) - 1.0;

        float r = 0.001;
        if (gl_InstanceID == 0) {
            v = vec3(y, r*cos(2.0*3.1416*x), r*sin(2.0*3.1416*x));
        } else if (gl_InstanceID == 1) {
            v = vec3(r*cos(2.0*3.1416*x), y, r*sin(2.0*3.1416*x));
        } else if (gl_InstanceID == 2) {
            v = vec3(r*cos(2.0*3.1416*x), r*sin(2.0*3.1416*x), y);
        }
    }

    // input, offset to center model
    v = qrot(v - d_pivot, q_pivot) + d_pivot + d_model;

    // model to world space (i.e. controller models)
    v = qrot(v, q_model) + p_model;

    // passthrough to fragment shader
    TexCoords = vertexUV;
    Normal = qrot(vertexNormal, q_model);
    WorldPos = v;

    // world space to camera space,
    v = qrot(v - p_hmd, qconj(q_hmd));

    // output, view space to clip space
    gl_Position = P*vec4(v, 1.0);
}

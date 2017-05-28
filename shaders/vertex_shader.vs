#version 330 core

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 vertexUV;

uniform float time;

uniform vec3 p_model;
uniform vec4 q_model;

uniform vec3 p_hmd;
uniform vec4 q_hmd;

uniform mat4 P; // perspective projection matrix, per-eye

out vec2 uv;
out vec3 pos;


vec3 qrot(vec3 p, vec4 q)
{ 
    // http://www.geeks3d.com/20141201/how-to-rotate-a-vertex-by-a-quaternion-in-glsl/
    return p + 2.0 * cross(q.xyz, cross(q.xyz, p) + q.w * p);
}

vec4 qconj(vec4 q)
{ 
    return vec4(-q.x, -q.y, -q.z, q.w); 
}

void main()
{
    // input
    vec3 v = vertexPosition;

    // model to world space (i.e. controller models)
    v = qrot(v, q_model) + p_model;

    // world space to camera space,
    v = qrot(v - p_hmd, qconj(q_hmd));

    // output, view space to clip space
    gl_Position = P*vec4(v, 1.0);
    
    // passthrough to fragment shader
    uv = vertexUV;
    pos = vertexPosition;
}

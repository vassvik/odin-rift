#version 330 core

in vec2 uv;
in vec3 pos;

uniform int apply_texture;
uniform sampler2D texture_sampler;

out vec4 color;

void main()
{
    if (apply_texture == 1) {
        color = vec4(texture(texture_sampler, uv).rgb, 1.0);
    } else {
        color = vec4(0.3, 0.4, 0.5, 1.0);

        vec3 uv2 = fract(4*1.000*pos + 0.5) - 0.5; // add and subtract half a unit to get centered lines 
        vec3 uv3 = fract(4*0.125*pos + 0.5) - 0.5;

        // base thickness, does not scale properly with desolution
        float t = 0.005;
        
        // thickness thin line
        float d2 = 1.0*t;
        
        // thickness thick line
        float d3 = 4.0*t/8.0;

        // falloff after 1.0 thickness, does not scale with resolution
        float s2 = smoothstep(d2*1.0, d2*2.5, min(abs(uv2.x), abs(uv2.z)));
        float s3 = smoothstep(d3*1.0, d3*1.25, min(abs(uv3.x), abs(uv3.z)));
        
        // coloring
        vec4 bgColor = vec4(0.95*155/255.0, 0.95*156/255.0, 0.95*159/255.0, 1.0);
        vec4 fgColor = vec4(0.95*78/255.0, 0.95*81/255.0, 0.95*88/255.0, 1.0);
        //vec4 fgColor = vec4(0.00, 0.00, 0.00, 1.0);
        
        color  = bgColor*s2 + fgColor*(1.0 - s2);
        color *= bgColor*s3 + fgColor*(1.0 - s3);
    }
}
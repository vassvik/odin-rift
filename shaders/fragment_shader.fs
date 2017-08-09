#version 330 core

in vec2 uv;
in vec3 pos;
in vec3 normal; 

uniform int apply_texture;
uniform sampler2D texture_sampler;

uniform int AA;

out vec4 color;

float inside_grid(vec2 p, float m, float t) {
    p = fract(m*p + 0.5) - 0.5;

    if (min(abs(p.x), abs(p.y)) < t) {
        return 1.0;
    } else {
        return 0.0;
    }


}

void main()
{
    if (apply_texture == 1) {
        color = vec4(texture(texture_sampler, uv).rgb, 1.0);
        if (abs(pos.x) < 0.002) {
            color = vec4(1.0, 0.0, 0.0, 1.0);
        }
        if (abs(pos.y) < 0.002) {
            color = vec4(0.0, 1.0, 0.0, 1.0);
        }
        if (abs(pos.z) < 0.002) {
            color = vec4(0.0, 0.0, 1.0, 1.0);
        }





    } else {
        vec2 dpdx = dFdx(uv);
        vec2 dpdy = dFdy(uv);

        // WARNING: Terrible anti-aliasing!
        float dx = 1.0/AA;
        float dy = 1.0/AA;
        float c = 0.0;
        for (int j = 0; j < AA; j++) {
            for (int i = 0; i < AA; i++) {
                vec2 p = uv + (-0.5 + (i + 0.5)*dx)*dpdx + (-0.5 + (j + 0.5)*dy)*dpdy;
                c += (1.0 - inside_grid(p, 1.0, 0.005));
            }
        }
        c /= AA*AA;

        vec3 bgColor = 0.5 + 0.5*normal;
        vec3 fgColor = vec3(0.0, 0.0, 0.0);
        color = vec4(vec3(bgColor*c + fgColor*(1.0 - c)), 1.0);

    }
}


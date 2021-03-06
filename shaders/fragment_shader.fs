#version 450 core

out vec4 FragColor;


in vec2 TexCoords;
in vec3 WorldPos;
in vec3 Normal;


const float PI = 3.14159265359;

uniform int apply_texture;
uniform int AA;

uniform vec3 coordinate_color;


// material parameters
uniform vec3  albedo;
uniform float metallic;
uniform float roughness;
uniform float ao;

// lights
uniform vec3 lightPositions[4];
uniform vec3 lightColors[4];

uniform vec3 camPos;

  
// ----------------------------------------------------------------------------
float DistributionGGX(vec3 N, vec3 H, float roughness);
float GeometrySchlickGGX(float NdotV, float roughness);
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness);
vec3 fresnelSchlick(float cosTheta, vec3 F0);
float CalculateAttenuation(vec3 lp, float lr, vec3 FragPos);

float inside_grid(vec2 p, float m, float t);

void main()
{       
    if (apply_texture == 1) {
        vec3 N = normalize(Normal);
        vec3 V = normalize(camPos - WorldPos);

        // calculate reflectance at normal incidence; if dia-electric (like plastic) use F0 
        // of 0.04 and if it's a metal, use the albedo color as F0 (metallic workflow)    
        vec3 F0 = vec3(0.04); 
        F0 = mix(F0, albedo, metallic);

        // reflectance equation
        vec3 Lo = vec3(0.0);
        for(int i = 0; i < 4; ++i) 
        {
            // calculate per-light radiance
            vec3 L = normalize(lightPositions[i] - WorldPos);
            vec3 H = normalize(V + L);
            float distance = length(lightPositions[i] - WorldPos);
            float attenuation = 1.0 / (distance * distance);
            vec3 radiance = lightColors[i] * attenuation;

            // Cook-Torrance BRDF
            float NDF = DistributionGGX(N, H, roughness);   
            float G   = GeometrySmith(N, V, L, roughness);      
            vec3 F    = fresnelSchlick(max(dot(H, V), 0.0), F0);
               
            vec3 nominator    = NDF * G * F; 
            float denominator = 4 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001; // 0.001 to prevent divide by zero.
            vec3 specular = nominator / denominator;
            
            // kS is equal to Fresnel
            vec3 kS = F;
            // for energy conservation, the diffuse and specular light can't
            // be above 1.0 (unless the surface emits light); to preserve this
            // relationship the diffuse component (kD) should equal 1.0 - kS.
            vec3 kD = vec3(1.0) - kS;
            // multiply kD by the inverse metalness such that only non-metals 
            // have diffuse lighting, or a linear blend if partly metal (pure metals
            // have no diffuse light).
            kD *= 1.0 - metallic;     

            // scale light by NdotL
            float NdotL = max(dot(N, L), 0.0);        

            // add to outgoing radiance Lo
            Lo += (kD * albedo / PI + specular) * radiance * NdotL;  // note that we already multiplied the BRDF by the Fresnel (kS) so we won't multiply by kS again
        }   
        
        // ambient lighting (note that the next IBL tutorial will replace 
        // this ambient lighting with environment lighting).
        vec3 ambient = vec3(0.03) * albedo * ao;

        vec3 color = ambient + Lo;

        // HDR tonemapping
        color = color / (color + vec3(1.0));
        // gamma correct
        color = pow(color, vec3(1.0/2.2)); 

        FragColor = vec4(color, 1.0);
        //FragColor = vec4(0.5 + 0.5*normalize(Normal), 1.0);
    } else if (apply_texture == 0) {
        vec2 dpdx = dFdx(TexCoords);
        vec2 dpdy = dFdy(TexCoords);

        // WARNING: Terrible anti-aliasing!
        float dx = 1.0/AA;
        float dy = 1.0/AA;
        float c = 0.0;
        for (int j = 0; j < AA; j++) {
            for (int i = 0; i < AA; i++) {
                vec2 p = TexCoords + (-0.5 + (i + 0.5)*dx)*dpdx + (-0.5 + (j + 0.5)*dy)*dpdy;
                c += (1.0 - inside_grid(p, 1.0, 0.005));
            }
        }
        c /= AA*AA;

        vec3 bgColor = 0.5 + 0.5*Normal;
        vec3 fgColor = vec3(0.0, 0.0, 0.0);
        vec4 color = vec4(vec3(bgColor*c + fgColor*(1.0 - c)), 1.0);
        FragColor = color;
    } else {
        FragColor = vec4(coordinate_color, 1.0);
    }
    
}  

float inside_grid(vec2 p, float m, float t) {
    p = fract(m*p + 0.5) - 0.5;

    if (min(abs(p.x), abs(p.y)) < t) {
        return 1.0;
    } else {
        return 0.0;
    }
}

float CalculateAttenuation(vec3 lp, float lr, vec3 FragPos) {
    float distance = distance(lp, FragPos);

    float saturated = pow(clamp(1 - pow(distance / lr, 4), 0.0, 1.0), 2);

    return saturated / (pow(distance, 2) + 1);
}

// ----------------------------------------------------------------------------
float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a = roughness*roughness;
    float a2 = a*a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}
// ----------------------------------------------------------------------------
vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}
// ----------------------------------------------------------------------------
//!DESC Clean Sharp and Vivid
//!HOOK MAIN
//!BIND HOOKED

#define SHARPNESS 0.5
#define SATURATION 1.7

vec4 hook() {
    vec4 original = HOOKED_tex(HOOKED_pos);
    vec3 color = original.rgb;
    
    // Aumento de saturação limpo
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, SATURATION);
    
    // Nitidez direta
    vec3 blur1 = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    vec3 blur2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 blur3 = HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    vec3 blur4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    
    vec3 average = (blur1 + blur2 + blur3 + blur4) / 4.0;
    vec3 edge = color - average;
    color += edge * SHARPNESS;
    
    // Pequeno boost final de cores
    color *= 1.1;
    
    return vec4(clamp(color, 0.0, 1.0), original.a);
}
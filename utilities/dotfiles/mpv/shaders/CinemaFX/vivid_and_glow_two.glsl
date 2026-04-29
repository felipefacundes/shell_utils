//!DESC Simple Vivid and Glow Shader
//!HOOK MAIN
//!BIND HOOKED

#define SATURATION 1.4
#define SHARPNESS 0.2
#define GLOW_INTENSITY 0.15

vec4 hook() {
    vec4 original = HOOKED_tex(HOOKED_pos);
    vec3 color = original.rgb;
    
    // Aumento simples de saturação
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, SATURATION);
    
    // Nitidez simples
    vec3 blur = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    blur += HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    blur += HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    blur += HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    blur /= 4.0;
    
    color = mix(color, color + (color - blur) * SHARPNESS, 0.5);
    
    // Glow simples
    vec3 glow = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    glow += HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    glow += HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    glow += HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    glow /= 4.0;
    
    color = mix(color, max(color, glow), GLOW_INTENSITY);
    
    return vec4(clamp(color, 0.0, 1.0), original.a);
}
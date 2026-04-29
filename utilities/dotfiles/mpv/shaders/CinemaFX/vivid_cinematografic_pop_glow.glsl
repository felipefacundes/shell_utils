//!DESC Extreme Vivid and Glow Shader
//!HOOK MAIN
//!BIND HOOKED

#define SHARPNESS 0.7
#define SATURATION 2.2
#define GLOW_INTENSITY 0.6
#define COLOR_POP 1.3

vec4 hook() {
    vec4 original = HOOKED_tex(HOOKED_pos);
    vec3 color = original.rgb;
    
    // Saturação extrema
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, SATURATION);
    
    // Boost de cores individuais
    color.r = pow(color.r, 1.0 / COLOR_POP);
    color.g = pow(color.g, 1.0 / COLOR_POP);
    color.b = pow(color.b, 1.0 / COLOR_POP);
    
    // Nitidez extrema
    vec3 blur1 = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    vec3 blur2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 blur3 = HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    vec3 blur4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 blur5 = HOOKED_texOff(vec2(1.0, 1.0)).rgb;
    vec3 blur6 = HOOKED_texOff(vec2(-1.0, -1.0)).rgb;
    vec3 blur7 = HOOKED_texOff(vec2(1.0, -1.0)).rgb;
    vec3 blur8 = HOOKED_texOff(vec2(-1.0, 1.0)).rgb;
    
    vec3 average = (blur1 + blur2 + blur3 + blur4 + blur5 + blur6 + blur7 + blur8) / 8.0;
    vec3 edge = color - average;
    color += edge * SHARPNESS;
    
    // Glow extremo
    vec3 glow = (blur1 + blur2 + blur3 + blur4) * 0.8;
    glow += (blur5 + blur6 + blur7 + blur8) * 0.6;
    glow /= 5.6;
    
    color = mix(color, max(color, glow * 1.2), GLOW_INTENSITY);
    
    return vec4(clamp(color, 0.0, 1.0), original.a);
}
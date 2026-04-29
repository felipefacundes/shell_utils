//!DESC Sharp and Vivid Shader
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define SHARPNESS_STRENGTH 0.3
#define VIBRANCE_STRENGTH 1.4

// Função para aumentar a vivacidade (corrigida)
vec3 applyVibrance(vec3 color, float strength) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, strength);
}

// Função alternativa de saturação mais simples
vec3 applySaturation(vec3 color, float saturation) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, saturation);
}

// Função para aplicar nitidez (mais suave)
vec3 applySharpness(vec3 color, float strength) {
    vec3 sample1 = HOOKED_texOff(vec2(-1.0, -1.0)).rgb;
    vec3 sample2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 sample3 = HOOKED_texOff(vec2(1.0, -1.0)).rgb;
    vec3 sample4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 sample5 = HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    vec3 sample6 = HOOKED_texOff(vec2(-1.0, 1.0)).rgb;
    vec3 sample7 = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    vec3 sample8 = HOOKED_texOff(vec2(1.0, 1.0)).rgb;
    
    // Média dos pixels vizinhos
    vec3 average = (sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) / 8.0;
    
    // Realce de bordas simples
    vec3 edge = color - average;
    return color + edge * strength;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // Aplica saturação/vivacidade PRIMEIRO
    vec3 saturatedColor = applySaturation(color, VIBRANCE_STRENGTH);
    
    // Aplica nitidez
    vec3 sharpColor = applySharpness(saturatedColor, SHARPNESS_STRENGTH * 0.5);
    
    // Garante que as cores não ultrapassem 1.0
    sharpColor = clamp(sharpColor, 0.0, 1.0);
    
    return vec4(sharpColor, originalColor.a);
}
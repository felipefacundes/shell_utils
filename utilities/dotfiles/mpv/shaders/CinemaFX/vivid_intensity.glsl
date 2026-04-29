//!DESC Sharp and Vivid Shader
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define SHARPNESS_STRENGTH 0.4
#define VIBRANCE_STRENGTH 1.6
#define COLOR_BOOST 1.1

// Função para aumentar a vivacidade
vec3 applyVibrance(vec3 color, float strength) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luminance), color, strength);
    return saturated;
}

// Função de boost de cores limpa
vec3 applyColorBoost(vec3 color, float boost) {
    // Aumenta a intensidade das cores sem distorcer
    return color * boost;
}

// Nitidez limpa e eficiente
vec3 applySharpness(vec3 color, float strength) {
    // Amostras para nitidez
    vec3 sample1 = HOOKED_texOff(vec2(-1.0, -1.0)).rgb;
    vec3 sample2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 sample3 = HOOKED_texOff(vec2(1.0, -1.0)).rgb;
    vec3 sample4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 sample5 = HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    vec3 sample6 = HOOKED_texOff(vec2(-1.0, 1.0)).rgb;
    vec3 sample7 = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    vec3 sample8 = HOOKED_texOff(vec2(1.0, 1.0)).rgb;
    
    // Média dos vizinhos
    vec3 average = (sample1 + sample2 + sample3 + sample4 + 
                   sample5 + sample6 + sample7 + sample8) / 8.0;
    
    // Realce de bordas suave
    vec3 edge = color - average;
    return color + edge * strength;
}

// Contraste sutil
vec3 applyContrast(vec3 color, float contrast) {
    return (color - 0.5) * contrast + 0.5;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // Aplica vivacidade primeiro
    vec3 vividColor = applyVibrance(color, VIBRANCE_STRENGTH);
    
    // Aplica boost de cores
    vec3 boostedColor = applyColorBoost(vividColor, COLOR_BOOST);
    
    // Aplica nitidez
    vec3 sharpColor = applySharpness(boostedColor, SHARPNESS_STRENGTH);
    
    // Aplica contraste sutil
    vec3 finalColor = applyContrast(sharpColor, 1.08);
    
    // Garante cores dentro do range
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, originalColor.a);
}
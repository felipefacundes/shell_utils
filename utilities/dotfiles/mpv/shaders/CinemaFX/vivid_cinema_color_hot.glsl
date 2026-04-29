//!DESC Cinema Color Grading (Tom Quente/Dourado)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define SATURATION_BOOST 1.4
#define CONTRAST 1.08
#define WARM_TINT 0.15
#define GOLDEN_HIGHLIGHTS 0.2

vec3 applyCinematicTone(vec3 color) {
    // Ajusta contraste de forma não-linear
    color = pow(color, vec3(CONTRAST));
    
    // Aumenta seletivamente a saturação
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, SATURATION_BOOST);
    
    // Aplica tom dourado/laranja nas altas luzes e amarelo nas sombras
    vec3 goldenHighlight = vec3(1.0, 0.9, 0.7);
    vec3 warmShadow = vec3(1.0, 0.85, 0.6);
    
    float highlightMask = pow(luminance, 2.0);
    float shadowMask = pow(1.0 - luminance, 2.0);
    
    // Aplica tons quentes de forma mais pronunciada
    color = mix(color, color * goldenHighlight, highlightMask * GOLDEN_HIGHLIGHTS);
    color = mix(color, color * warmShadow, shadowMask * WARM_TINT);
    
    // Reforço adicional de tom quente geral
    color.r *= 1.08;
    color.g *= 1.03;
    color.b *= 0.95;
    
    return color;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // Aplica a correção de cor cinematográfica
    vec3 finalColor = applyCinematicTone(color);
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, originalColor.a);
}
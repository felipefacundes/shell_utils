//!DESC Cinema Color Grading (Tom Frio/Azulado)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define SATURATION_BOOST 1.2
#define CONTRAST 1.08
#define BLUE_TINT 0.15
#define COLD_HIGHLIGHTS 0.08

vec3 applyCinematicTone(vec3 color) {
    // Ajusta contraste de forma não-linear
    color = pow(color, vec3(CONTRAST));
    
    // Aumenta seletivamente a saturação (mais conservador para tom frio)
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, SATURATION_BOOST);
    
    // Tons frios - azul nas sombras e ciano/azul claro nas altas luzes
    vec3 coldHighlight = vec3(0.8, 0.9, 1.0);
    vec3 blueShadow = vec3(0.7, 0.8, 1.0);
    
    float highlightMask = pow(luminance, 2.0);
    float shadowMask = pow(1.0 - luminance, 2.0);
    
    // Aplica tons frios de forma mais pronunciada
    color = mix(color, color * coldHighlight, highlightMask * COLD_HIGHLIGHTS);
    color = mix(color, color * blueShadow, shadowMask * BLUE_TINT);
    
    // Reforço adicional de tom azul geral
    color.b *= 1.05;
    color.r *= 0.98;
    
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
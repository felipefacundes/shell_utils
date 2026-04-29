//!DESC Cinema Color Grading (Laranja e Azul)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define SATURATION_BOOST 1.3
#define CONTRAST 1.1
#define BLUE_TINT 0.05
#define ORANGE_HIGHLIGHTS 0.1

vec3 applyCinematicTone(vec3 color) {
    // Ajusta contraste de forma não-linear
    color = pow(color, vec3(CONTRAST));
    
    // Aumenta seletivamente a saturação
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, SATURATION_BOOST);
    
    // Aplica tom laranja nas altas luzes e azul nas sombras
    vec3 orangeTint = vec3(1.0, 0.8, 0.6);
    vec3 blueTint = vec3(0.6, 0.8, 1.0);
    
    float highlightMask = pow(luminance, 2.0);
    float shadowMask = pow(1.0 - luminance, 2.0);
    
    color = mix(color, color * orangeTint, highlightMask * ORANGE_HIGHLIGHTS);
    color = mix(color, color * blueTint, shadowMask * BLUE_TINT);
    
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

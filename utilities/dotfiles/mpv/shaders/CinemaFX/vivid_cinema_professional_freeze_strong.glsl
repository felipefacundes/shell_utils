//!DESC Cinema Color Grading (Tom Muito Frio/Azulado)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define SATURATION_BOOST 1.1
#define CONTRAST 1.05
#define BLUE_TINT 0.25
#define COLD_HIGHLIGHTS 0.15

vec3 applyCinematicTone(vec3 color) {
    // Ajusta contraste de forma não-linear
    color = pow(color, vec3(CONTRAST));
    
    // Saturação mais conservadora para tom muito frio
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, SATURATION_BOOST);
    
    // Tons muito frios - azul intenso nas sombras e ciano forte nas altas luzes
    vec3 coldHighlight = vec3(0.7, 0.85, 1.0);
    vec3 blueShadow = vec3(0.6, 0.75, 1.0);
    
    float highlightMask = pow(luminance, 2.0);
    float shadowMask = pow(1.0 - luminance, 2.0);
    
    // Aplica tons frios de forma muito pronunciada
    color = mix(color, color * coldHighlight, highlightMask * COLD_HIGHLIGHTS);
    color = mix(color, color * blueShadow, shadowMask * BLUE_TINT);
    
    // Reforço intenso de tom azul geral
    color.b *= 1.12;
    color.r *= 0.92;
    color.g *= 0.97;
    
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
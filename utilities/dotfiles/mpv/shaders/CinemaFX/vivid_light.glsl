//!DESC Premium Theater Mode (Ultra Bright)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis - MÁXIMA LUMINOSIDADE
#define BRIGHTNESS_BOOST 1.25
#define CONTRAST_CURVE 1.05
#define VIGNETTE_STRENGTH 0.15
#define FILM_GRAIN_STRENGTH 0.005

// Função para brilho máximo mantendo detalhes
vec3 applyBrightnessBoost(vec3 color) {
    // Boost não-linear para preservar altas luzes
    color = pow(color, vec3(0.95)); // Curva inversa para clarear
    color *= BRIGHTNESS_BOOST;
    return color;
}

// Função para contraste muito suave
vec3 applySoftContrast(vec3 color) {
    // Curva mínima de contraste
    color = pow(color, vec3(CONTRAST_CURVE));
    return color;
}

// Função para vinheta super suave
vec3 applySoftVignette(vec3 color, vec2 uv) {
    // Vinheta quase imperceptível
    vec2 centered = uv - 0.5;
    float vignette = 1.0 - dot(centered, centered) * VIGNETTE_STRENGTH;
    vignette = smoothstep(0.6, 1.0, vignette); // Muito aberta
    return color * vignette;
}

// Função para grão quase invisível
vec3 applyMicroGrain(vec3 color, vec2 uv) {
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    noise = (noise - 0.5) * 2.0 * FILM_GRAIN_STRENGTH;
    return color + noise * 0.02;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. BRILHO MÁXIMO primeiro
    color = applyBrightnessBoost(color);
    
    // 2. Contraste quase natural
    color = applySoftContrast(color);
    
    // 3. Vinheta super suave
    color = applySoftVignette(color, uv);
    
    // 4. Grão microscópico
    color = applyMicroGrain(color, uv);
    
    // Garante que não estoure as cores
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
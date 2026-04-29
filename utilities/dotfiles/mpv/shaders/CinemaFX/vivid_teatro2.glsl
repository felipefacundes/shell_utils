//!DESC Premium Theater Mode (Bright Edition)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define CINEMATIC_BLACKS 0.15
#define FILM_GRAIN_STRENGTH 0.015
#define VIGNETTE_STRENGTH 0.3
#define WARM_THEATER_TINT 0.08
#define CONTRAST_CURVE 1.15
#define COLOR_FIDELITY 0.98
#define BRIGHTNESS_BOOST 1.1

// Função para pretos cinematográficos mais claros
vec3 applyCinematicBlacks(vec3 color, float depth) {
    // Curva de tons mais suave para pretos menos profundos
    color = pow(color, vec3(1.05));
    
    // Compressão de pretos mais leve
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float blackLevel = smoothstep(0.0, 0.08, luminance);
    color = mix(color * 0.6, color, blackLevel);
    
    return color;
}

// Função para grão de filme sutil
vec3 applyFilmGrain(vec3 color, vec2 uv, float strength) {
    // Noise procedural suave
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    noise = (noise - 0.5) * 2.0 * strength;
    
    // Aplica apenas em áreas de média luminância
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float grainMask = smoothstep(0.15, 0.7, luminance);
    
    return color + (noise * 0.08 * grainMask);
}

// Função para vinheta mais suave
vec3 applyTheaterVignette(vec3 color, vec2 uv, float strength) {
    // Vinheta oval mais aberta
    vec2 centered = uv - 0.5;
    float vignette = 1.0 - dot(centered, centered) * strength;
    
    // Aplica curva mais suave
    vignette = smoothstep(0.2, 1.0, vignette);
    
    return color * vignette;
}

// Função para cores de teatro premium (mais vivas)
vec3 applyTheaterColors(vec3 color, float warmth) {
    // Tom âmbar mais suave
    vec3 warmTint = vec3(1.01, 0.99, 0.98);
    
    // Aplica tom quente de forma mais sutil
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float warmMask = smoothstep(0.4, 0.8, luminance);
    
    color = mix(color, color * warmTint, warmth * warmMask);
    
    // Saturação mais próxima do original
    color = mix(vec3(luminance), color, COLOR_FIDELITY);
    
    return color;
}

// Função para contraste mais equilibrado
vec3 applyFilmContrast(vec3 color) {
    // Curva S mais suave
    color = pow(color, vec3(CONTRAST_CURVE));
    
    // Compressão de altas luzes mais leve
    color = 1.0 - exp(-color * 0.8);
    
    // Boost de brilho geral
    color *= BRIGHTNESS_BOOST;
    
    return color;
}

// Função para suavização de textura (mais leve)
vec3 applyFilmTexture(vec3 color) {
    // Suavização mínima para manter nitidez
    vec3 blur1 = HOOKED_texOff(vec2(0.5, 0.5)).rgb * 0.05;
    vec3 blur2 = HOOKED_texOff(vec2(-0.5, -0.5)).rgb * 0.05;
    
    color = mix(color, (color + blur1 + blur2) / 1.1, 0.03);
    
    return color;
}

// Função para realce seletivo de detalhes (preservado)
vec3 applySelectiveDetail(vec3 color) {
    // Realce sutil em áreas de alto detalhe
    vec3 dx = HOOKED_texOff(vec2(1.0, 0.0)).rgb - HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 dy = HOOKED_texOff(vec2(0.0, 1.0)).rgb - HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 detail = (dx * dx + dy * dy) * 0.08;
    
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float detailMask = smoothstep(0.4, 0.8, luminance);
    
    return color + detail * detailMask * 0.15;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Boost de brilho inicial leve
    color *= 1.05;
    
    // 2. Contraste cinematográfico suave
    vec3 contrastColor = applyFilmContrast(color);
    
    // 3. Pretos menos profundos
    vec3 cinematicBlacks = applyCinematicBlacks(contrastColor, CINEMATIC_BLACKS);
    
    // 4. Cores de teatro premium (mais vivas)
    vec3 theaterColors = applyTheaterColors(cinematicBlacks, WARM_THEATER_TINT);
    
    // 5. Detalhes seletivos
    vec3 detailed = applySelectiveDetail(theaterColors);
    
    // 6. Textura de filme mínima
    vec3 filmTexture = applyFilmTexture(detailed);
    
    // 7. Vinheta mais suave
    vec3 vignetted = applyTheaterVignette(filmTexture, uv, VIGNETTE_STRENGTH);
    
    // 8. Grão de filme quase imperceptível
    vec3 finalColor = applyFilmGrain(vignetted, uv, FILM_GRAIN_STRENGTH);
    
    finalColor = clamp(finalColor, 0.01, 0.99);
    
    return vec4(finalColor, originalColor.a);
}
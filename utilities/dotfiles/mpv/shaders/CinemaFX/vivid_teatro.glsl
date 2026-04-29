//!DESC Premium Theater Mode
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define CINEMATIC_BLACKS 0.3
#define FILM_GRAIN_STRENGTH 0.02
#define VIGNETTE_STRENGTH 0.4
#define WARM_THEATER_TINT 0.1
#define CONTRAST_CURVE 1.25
#define COLOR_FIDELITY 0.95

// Função para pretos cinematográficos profundos
vec3 applyCinematicBlacks(vec3 color, float depth) {
    // Curva de tons suave para pretos ricos
    color = pow(color, vec3(1.1));
    
    // Compressão de pretos para maior profundidade
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float blackLevel = smoothstep(0.0, 0.1, luminance);
    color = mix(color * 0.3, color, blackLevel);
    
    return color;
}

// Função para grão de filme sutil
vec3 applyFilmGrain(vec3 color, vec2 uv, float strength) {
    // Noise procedural suave
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    noise = (noise - 0.5) * 2.0 * strength;
    
    // Aplica apenas em áreas de média luminância
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float grainMask = smoothstep(0.2, 0.8, luminance);
    
    return color + (noise * 0.1 * grainMask);
}

// Função para vinheta cinematográfica
vec3 applyTheaterVignette(vec3 color, vec2 uv, float strength) {
    // Vinheta oval suave
    vec2 centered = uv - 0.5;
    float vignette = 1.0 - dot(centered, centered) * strength;
    
    // Aplica curva suave
    vignette = smoothstep(0.0, 1.0, vignette);
    
    return color * vignette;
}

// Função para cores de teatro premium
vec3 applyTheaterColors(vec3 color, float warmth) {
    // Tom âmbar suave típico de salas de cinema
    vec3 warmTint = vec3(1.02, 0.98, 0.96);
    
    // Aplica tom quente de forma gradual
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float warmMask = smoothstep(0.3, 0.7, luminance);
    
    color = mix(color, color * warmTint, warmth * warmMask);
    
    // Saturação levemente reduzida para look cinematográfico
    color = mix(vec3(luminance), color, COLOR_FIDELITY);
    
    return color;
}

// Função para contraste de cinema
vec3 applyFilmContrast(vec3 color) {
    // Curva S suave para contraste cinematográfico
    color = pow(color, vec3(CONTRAST_CURVE));
    
    // Compressão de altas luzes suave
    color = 1.0 - exp(-color * 1.2);
    
    return color;
}

// Função para suavização de textura (simula projeção)
vec3 applyFilmTexture(vec3 color) {
    // Suavização muito sutil para simular granulação de filme
    vec3 blur1 = HOOKED_texOff(vec2(0.5, 0.5)).rgb * 0.1;
    vec3 blur2 = HOOKED_texOff(vec2(-0.5, -0.5)).rgb * 0.1;
    
    color = mix(color, (color + blur1 + blur2) / 1.2, 0.05);
    
    return color;
}

// Função para realce seletivo de detalhes
vec3 applySelectiveDetail(vec3 color) {
    // Realce muito sutil apenas em áreas de alto detalhe
    vec3 dx = HOOKED_texOff(vec2(1.0, 0.0)).rgb - HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 dy = HOOKED_texOff(vec2(0.0, 1.0)).rgb - HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 detail = (dx * dx + dy * dy) * 0.1;
    
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float detailMask = smoothstep(0.3, 0.7, luminance);
    
    return color + detail * detailMask * 0.2;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Contraste cinematográfico primeiro
    vec3 contrastColor = applyFilmContrast(color);
    
    // 2. Pretos profundos de cinema
    vec3 cinematicBlacks = applyCinematicBlacks(contrastColor, CINEMATIC_BLACKS);
    
    // 3. Cores de teatro premium
    vec3 theaterColors = applyTheaterColors(cinematicBlacks, WARM_THEATER_TINT);
    
    // 4. Detalhes seletivos
    vec3 detailed = applySelectiveDetail(theaterColors);
    
    // 5. Textura de filme sutil
    vec3 filmTexture = applyFilmTexture(detailed);
    
    // 6. Vinheta cinematográfica
    vec3 vignetted = applyTheaterVignette(filmTexture, uv, VIGNETTE_STRENGTH);
    
    // 7. Grão de filme final (muito sutil)
    vec3 finalColor = applyFilmGrain(vignetted, uv, FILM_GRAIN_STRENGTH);
    
    finalColor = clamp(finalColor, 0.001, 0.999); // Mantém pequena faixa dinâmica
    
    return vec4(finalColor, originalColor.a);
}
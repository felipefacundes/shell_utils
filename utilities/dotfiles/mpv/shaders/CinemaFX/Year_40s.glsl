//!DESC Vintage 1940s Film Effect (Light Version)
//!HOOK MAIN
//!BIND HOOKED

#define FILM_GRAIN_INTENSITY 0.08
#define SCRATCH_INTENSITY 0.2
#define DUST_INTENSITY 0.15
#define FILM_FADE 0.2
#define YELLOWING 0.6
#define FLICKER_INTENSITY 0.1
#define BRIGHTNESS_BOOST 1.3

// Função de noise para efeitos de filme
float film_noise(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Efeito de amarelamento mais suave
vec3 applyYellowing(vec3 color, float intensity) {
    // Tom amarelo mais claro e suave
    vec3 yellowTint = vec3(1.0, 0.95, 0.85);
    return mix(color, color * yellowTint, intensity);
}

// Grão de filme mais sutil
vec3 applyFilmGrain(vec3 color, vec2 uv, float time) {
    float grain = film_noise(uv * 600.0 + time) * 2.0 - 1.0;
    return color + grain * FILM_GRAIN_INTENSITY;
}

// Arranhões mais sutis
float filmScratches(vec2 uv, float time) {
    float scratch = 0.0;
    
    // Arranhões mais finos e menos intensos
    for(int i = 0; i < 2; i++) {
        float scratchPos = film_noise(vec2(float(i), floor(time * 1.5)));
        float scratchWidth = film_noise(vec2(float(i), 1.0)) * 0.001;
        float scratchIntensity = film_noise(vec2(float(i), 2.0)) * 0.5;
        
        if (abs(uv.y - scratchPos) < scratchWidth) {
            scratch = scratchIntensity * SCRATCH_INTENSITY;
        }
    }
    
    return scratch;
}

// Poeira mais leve
float filmDust(vec2 uv, float time) {
    float dust = 0.0;
    
    // Menos partículas de poeira
    for(int i = 0; i < 6; i++) {
        vec2 dustPos = vec2(film_noise(vec2(float(i), 0.0)), film_noise(vec2(float(i), 1.0)));
        float dustSize = film_noise(vec2(float(i), 2.0)) * 0.008;
        float dustLife = fract(time * 0.08 + float(i) * 0.3);
        
        if (distance(uv, dustPos) < dustSize * dustLife) {
            dust += film_noise(vec2(float(i), 3.0)) * DUST_INTENSITY * 0.7;
        }
    }
    
    return dust;
}

// Desbotamento reduzido
vec3 applyFilmFade(vec3 color, float intensity) {
    // Contraste mais preservado
    color = pow(color, vec3(0.95));
    
    // Dessaturação mínima
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(color, vec3(luminance), intensity * 0.15);
    
    return color;
}

// Tremor do projetor mais suave
vec2 projectorJitter(vec2 uv, float time) {
    float jitterX = (film_noise(vec2(time, 0.0)) - 0.5) * 0.001;
    float jitterY = (film_noise(vec2(time, 1.0)) - 0.5) * 0.0005;
    
    return uv + vec2(jitterX, jitterY);
}

// Piscadas de luz mais sutis
float filmFlicker(float time) {
    float flicker = sin(time * 8.0) * 0.05 + 
                   sin(time * 5.0) * 0.03 +
                   sin(time * 15.0) * 0.02;
    
    return 1.0 + flicker * FLICKER_INTENSITY;
}

// Manchas de queimado mais claras
vec3 filmBurnSpots(vec3 color, vec2 uv, float time) {
    float burn = 0.0;
    
    // Manchas mais claras e menos intensas
    for(int i = 0; i < 3; i++) {
        vec2 burnPos = vec2(film_noise(vec2(float(i) * 2.0, 0.0)), 
                           film_noise(vec2(float(i) * 2.0, 1.0)));
        float burnSize = film_noise(vec2(float(i) * 2.0, 2.0)) * 0.03;
        float burnIntensity = film_noise(vec2(float(i) * 2.0, 3.0)) * 0.2;
        
        if (distance(uv, burnPos) < burnSize) {
            burn = burnIntensity;
        }
    }
    
    // Escurecimento mais suave
    return color * (1.0 - burn * 0.5);
}

// Vinheta mais suave e clara
vec3 applyVignette(vec3 color, vec2 uv) {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - dist * 0.8; // Vinheta mais aberta
    vignette = smoothstep(0.3, 1.0, vignette); // Transição mais suave
    
    return color * vignette;
}

// Linhas de varredura mais sutis
vec3 applyScanLines(vec3 color, vec2 uv, float time) {
    float scanLine = sin(uv.y * 600.0 + time * 3.0) * 0.05 + 0.97;
    return color * scanLine;
}

// Boost de brilho geral
vec3 applyBrightness(vec3 color) {
    return color * BRIGHTNESS_BOOST;
}

// Preserva mais as cores originais
vec3 preserveOriginalColors(vec3 original, vec3 processed) {
    // Mantém mais da cor original nas áreas claras
    float luminance = dot(original, vec3(0.299, 0.587, 0.114));
    float preserveMask = smoothstep(0.3, 0.8, luminance);
    
    return mix(processed, original, preserveMask * 0.3);
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    float time = float(frame) / 60.0;
    
    // 1. Tremor do projetor suave
    uv = projectorJitter(uv, time);
    
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 2. Boost de brilho primeiro
    color = applyBrightness(color);
    
    // 3. Amarelamento suave
    color = applyYellowing(color, YELLOWING);
    
    // 4. Desbotamento mínimo
    color = applyFilmFade(color, FILM_FADE);
    
    // 5. Manchas de queimado sutis
    color = filmBurnSpots(color, uv, time);
    
    // 6. Vinheta suave
    color = applyVignette(color, uv);
    
    // 7. Preserva cores originais
    color = preserveOriginalColors(originalColor.rgb, color);
    
    // 8. Grão de filme sutil
    color = applyFilmGrain(color, uv, time);
    
    // 9. Arranhões leves
    float scratches = filmScratches(uv, time);
    color += vec3(scratches);
    
    // 10. Poeira sutil
    float dust = filmDust(uv, time);
    color += vec3(dust * 0.5);
    
    // 11. Linhas de varredura muito sutis
    color = applyScanLines(color, uv, time);
    
    // 12. Piscadas de luz mínimas
    color *= filmFlicker(time);
    
    // Garante os valores dentro do range
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
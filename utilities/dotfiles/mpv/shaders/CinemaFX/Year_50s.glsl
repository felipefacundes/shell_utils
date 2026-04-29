//!DESC Vintage 1940s Film Effect (Very Light Version)
//!HOOK MAIN
//!BIND HOOKED

#define FILM_GRAIN_INTENSITY 0.04
#define SCRATCH_INTENSITY 0.1
#define DUST_INTENSITY 0.08
#define FILM_FADE 0.1
#define YELLOWING 0.3
#define FLICKER_INTENSITY 0.05
#define BRIGHTNESS_BOOST 1.5

// Função de noise para efeitos de filme
float film_noise(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Efeito de amarelamento muito suave
vec3 applyYellowing(vec3 color, float intensity) {
    // Tom amarelo quase imperceptível
    vec3 yellowTint = vec3(1.02, 0.98, 0.95);
    return mix(color, color * yellowTint, intensity);
}

// Grão de filme quase invisível
vec3 applyFilmGrain(vec3 color, vec2 uv, float time) {
    float grain = film_noise(uv * 400.0 + time) * 2.0 - 1.0;
    return color + grain * FILM_GRAIN_INTENSITY;
}

// Arranhões muito sutis
float filmScratches(vec2 uv, float time) {
    float scratch = 0.0;
    
    // Apenas 1 arranhão muito sutil
    float scratchPos = film_noise(vec2(0.0, floor(time * 1.0)));
    float scratchWidth = 0.0005; // Muito fino
    float scratchIntensity = film_noise(vec2(1.0, 2.0)) * 0.3;
    
    if (abs(uv.y - scratchPos) < scratchWidth) {
        scratch = scratchIntensity * SCRATCH_INTENSITY;
    }
    
    return scratch;
}

// Poeira mínima
float filmDust(vec2 uv, float time) {
    float dust = 0.0;
    
    // Apenas 3 partículas de poeira
    for(int i = 0; i < 3; i++) {
        vec2 dustPos = vec2(film_noise(vec2(float(i), 0.0)), film_noise(vec2(float(i), 1.0)));
        float dustSize = film_noise(vec2(float(i), 2.0)) * 0.005;
        float dustLife = fract(time * 0.05 + float(i) * 0.4);
        
        if (distance(uv, dustPos) < dustSize * dustLife) {
            dust += film_noise(vec2(float(i), 3.0)) * DUST_INTENSITY * 0.4;
        }
    }
    
    return dust;
}

// Quase sem desbotamento
vec3 applyFilmFade(vec3 color, float intensity) {
    // Contraste quase original
    color = pow(color, vec3(0.98));
    
    // Quase sem dessaturação
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(color, vec3(luminance), intensity * 0.05);
    
    return color;
}

// Tremor do projetor mínimo
vec2 projectorJitter(vec2 uv, float time) {
    float jitterX = (film_noise(vec2(time, 0.0)) - 0.5) * 0.0003;
    float jitterY = (film_noise(vec2(time, 1.0)) - 0.5) * 0.0002;
    
    return uv + vec2(jitterX, jitterY);
}

// Piscadas de luz quase imperceptíveis
float filmFlicker(float time) {
    float flicker = sin(time * 5.0) * 0.02;
    return 1.0 + flicker * FLICKER_INTENSITY;
}

// Manchas de queimado muito leves
vec3 filmBurnSpots(vec3 color, vec2 uv, float time) {
    float burn = 0.0;
    
    // Apenas 1-2 manchas muito sutis
    for(int i = 0; i < 2; i++) {
        vec2 burnPos = vec2(film_noise(vec2(float(i) * 3.0, 0.0)), 
                           film_noise(vec2(float(i) * 3.0, 1.0)));
        float burnSize = film_noise(vec2(float(i) * 3.0, 2.0)) * 0.02;
        float burnIntensity = film_noise(vec2(float(i) * 3.0, 3.0)) * 0.1;
        
        if (distance(uv, burnPos) < burnSize) {
            burn = max(burn, burnIntensity);
        }
    }
    
    // Escurecimento mínimo
    return color * (1.0 - burn * 0.2);
}

// Vinheta muito suave
vec3 applyVignette(vec3 color, vec2 uv) {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - dist * 0.4; // Vinheta quase imperceptível
    vignette = smoothstep(0.5, 1.0, vignette); // Transição muito suave
    
    return color * vignette;
}

// Linhas de varredura quase invisíveis
vec3 applyScanLines(vec3 color, vec2 uv, float time) {
    float scanLine = sin(uv.y * 400.0 + time * 2.0) * 0.02 + 0.99;
    return color * scanLine;
}

// Boost de brilho significativo
vec3 applyBrightness(vec3 color) {
    return color * BRIGHTNESS_BOOST;
}

// Preserva a maioria das cores originais
vec3 preserveOriginalColors(vec3 original, vec3 processed) {
    float luminance = dot(original, vec3(0.299, 0.587, 0.114));
    float preserveMask = smoothstep(0.2, 0.7, luminance);
    
    // Mantém 80% da cor original na maioria das áreas
    return mix(processed, original, preserveMask * 0.8);
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    float time = float(frame) / 60.0;
    
    // 1. Tremor do projetor quase imperceptível
    uv = projectorJitter(uv, time);
    
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 2. Boost de brilho forte
    color = applyBrightness(color);
    
    // 3. Amarelamento muito suave
    color = applyYellowing(color, YELLOWING);
    
    // 4. Quase sem desbotamento
    color = applyFilmFade(color, FILM_FADE);
    
    // 5. Manchas de queimado mínimas
    color = filmBurnSpots(color, uv, time);
    
    // 6. Vinheta muito suave
    color = applyVignette(color, uv);
    
    // 7. Preserva a maioria das cores originais
    color = preserveOriginalColors(originalColor.rgb, color);
    
    // 8. Grão quase invisível
    color = applyFilmGrain(color, uv, time);
    
    // 9. Arranhões muito sutis
    float scratches = filmScratches(uv, time);
    color += vec3(scratches);
    
    // 10. Poeira mínima
    float dust = filmDust(uv, time);
    color += vec3(dust * 0.3);
    
    // 11. Linhas de varredura quase imperceptíveis
    color = applyScanLines(color, uv, time);
    
    // 12. Piscadas de luz mínimas
    color *= filmFlicker(time);
    
    // Garante os valores dentro do range
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
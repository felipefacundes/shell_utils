//!DESC Vintage 1940s Film Effect
//!HOOK MAIN
//!BIND HOOKED

#define FILM_GRAIN_INTENSITY 0.1
#define SCRATCH_INTENSITY 0.3
#define DUST_INTENSITY 0.2
#define FILM_FADE 0.4
#define YELLOWING 0.8
#define FLICKER_INTENSITY 0.2

// Função de noise para efeitos de filme
float film_noise(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Efeito de amarelamento do filme
vec3 applyYellowing(vec3 color, float intensity) {
    // Tom amarelo/envelhecido característico dos anos 40
    vec3 yellowTint = vec3(1.0, 0.9, 0.7);
    return mix(color, color * yellowTint, intensity);
}

// Grão de filme autêntico
vec3 applyFilmGrain(vec3 color, vec2 uv, float time) {
    float grain = film_noise(uv * 800.0 + time) * 2.0 - 1.0;
    return color + grain * FILM_GRAIN_INTENSITY;
}

// Arranhões de filme
float filmScratches(vec2 uv, float time) {
    // Arranhões horizontais que se movem
    float scratch = 0.0;
    
    // Arranhões principais
    for(int i = 0; i < 3; i++) {
        float scratchPos = film_noise(vec2(float(i), floor(time * 2.0)));
        float scratchWidth = film_noise(vec2(float(i), 1.0)) * 0.002;
        float scratchIntensity = film_noise(vec2(float(i), 2.0));
        
        if (abs(uv.y - scratchPos) < scratchWidth) {
            scratch = scratchIntensity * SCRATCH_INTENSITY;
        }
    }
    
    return scratch;
}

// Poeira e sujeira do projetor
float filmDust(vec2 uv, float time) {
    float dust = 0.0;
    
    // Partículas de poeira
    for(int i = 0; i < 10; i++) {
        vec2 dustPos = vec2(film_noise(vec2(float(i), 0.0)), film_noise(vec2(float(i), 1.0)));
        float dustSize = film_noise(vec2(float(i), 2.0)) * 0.01;
        float dustLife = fract(time * 0.1 + float(i) * 0.3);
        
        if (distance(uv, dustPos) < dustSize * dustLife) {
            dust += film_noise(vec2(float(i), 3.0)) * DUST_INTENSITY;
        }
    }
    
    return dust;
}

// Desbotamento e perda de contraste
vec3 applyFilmFade(vec3 color, float intensity) {
    // Reduz contraste e saturação
    color = pow(color, vec3(0.9)); // Contraste reduzido
    
    // Dessaturação
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(color, vec3(luminance), intensity * 0.3);
    
    return color;
}

// Tremor do projetor
vec2 projectorJitter(vec2 uv, float time) {
    float jitterX = (film_noise(vec2(time, 0.0)) - 0.5) * 0.002;
    float jitterY = (film_noise(vec2(time, 1.0)) - 0.5) * 0.001;
    
    return uv + vec2(jitterX, jitterY);
}

// Piscadas de luz (flicker)
float filmFlicker(float time) {
    float flicker = sin(time * 12.0) * 0.1 + 
                   sin(time * 7.0) * 0.05 +
                   sin(time * 23.0) * 0.03;
    
    return 1.0 + flicker * FLICKER_INTENSITY;
}

// Manchas de queimado do filme
vec3 filmBurnSpots(vec3 color, vec2 uv, float time) {
    float burn = 0.0;
    
    // Manchas de queimado
    for(int i = 0; i < 5; i++) {
        vec2 burnPos = vec2(film_noise(vec2(float(i) * 2.0, 0.0)), 
                           film_noise(vec2(float(i) * 2.0, 1.0)));
        float burnSize = film_noise(vec2(float(i) * 2.0, 2.0)) * 0.05;
        float burnIntensity = film_noise(vec2(float(i) * 2.0, 3.0)) * 0.4;
        
        if (distance(uv, burnPos) < burnSize) {
            burn = burnIntensity;
        }
    }
    
    // Escurece as áreas queimadas
    return color * (1.0 - burn);
}

// Efeito de vinheta pesada
vec3 applyVignette(vec3 color, vec2 uv) {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - dist * 1.5;
    vignette = smoothstep(0.0, 1.0, vignette);
    
    return color * vignette;
}

// Linhas de varredura (scan lines)
vec3 applyScanLines(vec3 color, vec2 uv, float time) {
    float scanLine = sin(uv.y * 800.0 + time * 5.0) * 0.1 + 0.9;
    return color * scanLine;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    float time = float(frame) / 60.0;
    
    // 1. Tremor do projetor
    uv = projectorJitter(uv, time);
    
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 2. Amarelamento forte do filme
    color = applyYellowing(color, YELLOWING);
    
    // 3. Desbotamento e perda de contraste
    color = applyFilmFade(color, FILM_FADE);
    
    // 4. Manchas de queimado
    color = filmBurnSpots(color, uv, time);
    
    // 5. Vinheta pesada
    color = applyVignette(color, uv);
    
    // 6. Grão de filme
    color = applyFilmGrain(color, uv, time);
    
    // 7. Arranhões
    float scratches = filmScratches(uv, time);
    color += vec3(scratches);
    
    // 8. Poeira
    float dust = filmDust(uv, time);
    color += vec3(dust);
    
    // 9. Linhas de varredura
    color = applyScanLines(color, uv, time);
    
    // 10. Piscadas de luz
    color *= filmFlicker(time);
    
    // Garante os valores dentro do range
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
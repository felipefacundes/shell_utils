//!DESC Godot World Environment Ultimate (Bloom Controlado)
//!HOOK MAIN
//!BIND HOOKED

#define TONEMAP_ACES
#define BLOOM_ENABLED
#define GLOBAL_ILLUMINATION
#define VIBRANT_COLORS

// Parâmetros CONTROLADOS para evitar estouro
#define SKY_COLOR vec3(0.3, 0.5, 0.7)
#define SUN_COLOR vec3(1.0, 0.85, 0.7)
#define AMBIENT_COLOR vec3(0.3, 0.4, 0.5)
#define BLOOM_INTENSITY 0.3
#define BLOOM_THRESHOLD 0.8

// Tonemapping ACES mais conservador
vec3 tonemapACES(vec3 x) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    vec3 result = (x * (a * x + b)) / (x * (c * x + d) + e);
    return pow(result, vec3(1.05)); // Menos contraste
}

// Bloom/Glow CONTROLADO
vec3 applyBloom(vec3 color, vec2 uv, float threshold, float intensity) {
    #ifdef BLOOM_ENABLED
    vec3 bloom = vec3(0.0);
    float totalWeight = 0.0;
    
    // Kernel de blur menor para bloom mais suave
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            vec2 offset = vec2(x, y) * (1.0 / HOOKED_size) * 1.5;
            vec3 sampleColor = HOOKED_tex(uv + offset).rgb;
            
            // Threshold MAIS ALTO - apenas cores MUITO brilhantes
            float brightness = dot(sampleColor, vec3(0.299, 0.587, 0.114));
            if (brightness > threshold) {
                float weight = 1.0 / (1.0 + length(vec2(x, y)));
                bloom += sampleColor * weight;
                totalWeight += weight;
            }
        }
    }
    
    if (totalWeight > 0.0) {
        bloom /= totalWeight;
        // Mistura MAIS SUAVE
        color = mix(color, max(color, bloom), intensity * 0.5);
    }
    #endif
    
    return color;
}

// Iluminação global MAIS SUAVE
vec3 applyGlobalIllumination(vec3 color, vec3 original) {
    #ifdef GLOBAL_ILLUMINATION
    float luminance = dot(original, vec3(0.299, 0.587, 0.114));
    
    // Bounced light menos intensa
    vec3 bouncedLight = SKY_COLOR * (luminance * 0.5 + 0.1);
    vec3 ambient = AMBIENT_COLOR * 0.2;
    
    // Combinação mais conservadora
    return mix(color, color * (bouncedLight + ambient), 0.2);
    #else
    return color;
    #endif
}

// Cores vivas mas CONTROLADAS
vec3 enhanceColors(vec3 color) {
    #ifdef VIBRANT_COLORS
    // Saturação equilibrada
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luminance), color, 1.4); // Reduzida de 1.8 para 1.4
    
    // Realce seletivo MAIS SUAVE
    saturated.r = pow(saturated.r, 0.92);  // Vermelhos controlados
    saturated.g = pow(saturated.g, 0.95);   // Verdes controlados
    saturated.b = pow(saturated.b, 1.02);   // Azuis quase neutros
    
    return saturated;
    #else
    return color;
    #endif
}

// Efeito de luz solar MAIS SUAVE
vec3 applySunLight(vec3 color, vec2 uv) {
    vec2 sunPos = vec2(0.8, 0.7);
    float sunDistance = distance(uv, sunPos);
    float sunIntensity = 1.0 - smoothstep(0.0, 0.4, sunDistance);
    
    // Glow MENOS intenso
    vec3 sunGlow = SUN_COLOR * pow(sunIntensity, 2.5) * 0.4; // Reduzido de 0.8 para 0.4
    
    return color + sunGlow;
}

// SSAO mantido
float applySSAO(vec2 uv) {
    vec2 texelSize = 1.0 / vec2(HOOKED_size);
    float occlusion = 0.0;
    float totalWeight = 0.0;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;
            vec2 offset = vec2(x, y) * texelSize * 1.5;
            vec3 sampleColor = HOOKED_tex(uv + offset).rgb;
            float sampleLuma = dot(sampleColor, vec3(0.299, 0.587, 0.114));
            float currentLuma = dot(HOOKED_tex(uv).rgb, vec3(0.299, 0.587, 0.114));

            if(sampleLuma < currentLuma - 0.08) {
                float weight = 1.0 / (1.0 + length(vec2(x, y)));
                occlusion += 0.1 * weight;
                totalWeight += weight;
            }
        }
    }

    return 1.0 - clamp(occlusion / max(totalWeight, 1.0), 0.0, 0.3);
}

// Atmosfera sutil
vec3 applyAtmosphere(vec3 color, vec2 uv) {
    float skyGradient = pow(uv.y, 0.8);
    vec3 atmosphere = mix(vec3(0.9, 0.95, 1.0), vec3(0.6, 0.7, 0.85), skyGradient);
    
    // Aplica com MENOS força
    return mix(color, color * atmosphere, 0.08); // Reduzido de 0.15 para 0.08
}

// Contraste SUAVE
vec3 applyContrast(vec3 color) {
    return pow(color, vec3(1.1)); // Reduzido de 1.2 para 1.1
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Cores base equilibradas
    color = enhanceColors(color);
    
    // 2. Iluminação global suave
    color = applyGlobalIllumination(color, originalColor.rgb);
    
    // 3. Luz solar controlada
    color = applySunLight(color, uv);
    
    // 4. Aplica SSAO
    float ssao = applySSAO(uv);
    color *= ssao;
    
    // 5. Atmosfera muito sutil
    color = applyAtmosphere(color, uv);
    
    // 6. BLOOM CONTROLADO
    color = applyBloom(color, uv, BLOOM_THRESHOLD, BLOOM_INTENSITY);
    
    // 7. Tonemapping conservador
    color = tonemapACES(color * 1.1); // Reduzido de 1.3 para 1.1
    
    // 8. Contraste final suave
    color = applyContrast(color);
    
    // Clamping rigoroso
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
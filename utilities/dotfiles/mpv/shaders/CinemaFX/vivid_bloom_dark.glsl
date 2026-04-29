//!DESC Godot World Environment Ultimate (Alegre & Controlado)
//!HOOK MAIN
//!BIND HOOKED

#define TONEMAP_ACES
#define BLOOM_ENABLED
#define GLOBAL_ILLUMINATION
#define VIBRANT_COLORS

// Parâmetros ALEGRES mas PRECISOS
#define SKY_COLOR vec3(0.25, 0.45, 0.75)
#define SUN_COLOR vec3(1.0, 0.9, 0.75)
#define AMBIENT_COLOR vec3(0.35, 0.45, 0.6)
#define BLOOM_INTENSITY 0.3
#define BLOOM_THRESHOLD 0.8

// Tonemapping ACES controlado
vec3 tonemapACES(vec3 x) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    vec3 result = (x * (a * x + b)) / (x * (c * x + d) + e);
    return pow(result, vec3(1.06)); // Contraste preciso
}

// Bloom/Glow PRECISO sem vazamento
vec3 applyBloom(vec3 color, vec2 uv, float threshold, float intensity) {
    #ifdef BLOOM_ENABLED
    vec3 bloom = vec3(0.0);
    float totalWeight = 0.0;
    
    for(int x = -2; x <= 2; x++) {
        for(int y = -2; y <= 2; y++) {
            vec2 offset = vec2(x, y) * (1.0 / HOOKED_size) * 1.5;
            vec3 sampleColor = HOOKED_tex(uv + offset).rgb;
            
            // Threshold ALTO - apenas áreas MUITO específicas
            float brightness = dot(sampleColor, vec3(0.299, 0.587, 0.114));
            if (brightness > threshold) {
                // Verifica se é uma cor pura (não branco vazado)
                float colorPurity = max(max(sampleColor.r, sampleColor.g), sampleColor.b) - min(min(sampleColor.r, sampleColor.g), sampleColor.b);
                if (colorPurity > 0.3) { // Só cores com identidade
                    float weight = 1.0 / (1.0 + length(vec2(x, y)) * 0.8);
                    bloom += sampleColor * weight;
                    totalWeight += weight;
                }
            }
        }
    }
    
    if (totalWeight > 0.0) {
        bloom /= totalWeight;
        // Mistura que PRESERVA as cores originais
        color = mix(color, max(color, bloom), intensity * 0.4);
    }
    #endif
    
    return color;
}

// Iluminação global PRECISA
vec3 applyGlobalIllumination(vec3 color, vec3 original) {
    #ifdef GLOBAL_ILLUMINATION
    float luminance = dot(original, vec3(0.299, 0.587, 0.114));
    
    // Bounced light colorida mas CONTIDA
    vec3 bouncedLight = SKY_COLOR * (luminance * 0.5 + 0.1);
    vec3 ambient = AMBIENT_COLOR * 0.2;
    
    // Combinação que não destrói cores originais
    vec3 illuminated = color * (bouncedLight + ambient);
    return mix(color, illuminated, 0.2);
    #else
    return color;
    #endif
}

// Cores ALEGRES mas FIÉIS
vec3 enhanceColors(vec3 color) {
    #ifdef VIBRANT_COLORS
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Saturação inteligente - evita estouro
    float baseSaturation = 1.45;
    vec3 saturated = mix(vec3(luminance), color, baseSaturation);
    
    // Detector de cores puras vs branco sujo
    float colorPurity = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    float purityMask = smoothstep(0.2, 0.5, colorPurity);
    
    // Só aplica boost em cores COM IDENTIDADE
    saturated = mix(color, saturated, purityMask);
    
    // Balanceamento PRECISO
    saturated.r = pow(saturated.r, 0.9);   // Vermelhos ricos
    saturated.g = pow(saturated.g, 0.94);  // Verdes frescos  
    saturated.b = pow(saturated.b, 0.99);  // Azuis quase neutros
    
    return saturated;
    #else
    return color;
    #endif
}

// Efeito de luz solar PRECISO
vec3 applySunLight(vec3 color, vec2 uv) {
    vec2 sunPos = vec2(0.8, 0.7);
    float sunDistance = distance(uv, sunPos);
    float sunIntensity = 1.0 - smoothstep(0.0, 0.4, sunDistance);
    
    // Glow controlado e localizado
    vec3 sunGlow = SUN_COLOR * pow(sunIntensity, 2.5) * 0.4;
    
    return color + sunGlow;
}

// SSAO para profundidade
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
    float skyGradient = pow(uv.y, 0.7);
    vec3 atmosphere = mix(vec3(0.95, 0.98, 1.02), vec3(0.5, 0.65, 0.85), skyGradient);
    
    return mix(color, color * atmosphere, 0.08);
}

// Contraste preciso
vec3 applyContrast(vec3 color) {
    return pow(color, vec3(1.08));
}

// Alegria seletiva e PRECISA
vec3 applyJoy(vec3 color) {
    // Só realça cores com boa saturação
    float colorPurity = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    float joyMask = smoothstep(0.25, 0.6, colorPurity);
    
    // Pequeno boost apenas em cores dignas
    color = mix(color, color * 1.03, joyMask * 0.4);
    
    return color;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Cores base fiéis
    color = enhanceColors(color);
    
    // 2. Alegria seletiva (ANTES da iluminação)
    color = applyJoy(color);
    
    // 3. Iluminação global precisa
    color = applyGlobalIllumination(color, originalColor.rgb);
    
    // 4. Luz solar controlada
    color = applySunLight(color, uv);
    
    // 5. Profundidade
    float ssao = applySSAO(uv);
    color *= ssao;
    
    // 6. Atmosfera sutil
    color = applyAtmosphere(color, uv);
    
    // 7. Bloom PRECISO (último - evita propagação)
    color = applyBloom(color, uv, BLOOM_THRESHOLD, BLOOM_INTENSITY);
    
    // 8. Tonemapping controlado
    color = tonemapACES(color * 1.08);
    
    // 9. Contraste final preciso
    color = applyContrast(color);
    
    // Clamping RIGOROSO
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
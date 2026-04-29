//!DESC Godot World Environment Inspired Shader (Vivid & Alive - Fixed)
//!HOOK MAIN
//!BIND HOOKED

#define TONEMAP_ACES
//#define FOG_ENABLED  // Desabilitado para evitar tom azul
#define GLOBAL_ILLUMINATION

// Parâmetros de atmosfera equilibrados
#define SKY_COLOR vec3(0.4, 0.5, 0.6)  // Menos azul
#define SUN_COLOR vec3(1.0, 0.95, 0.9) // Mais neutro
#define AMBIENT_COLOR vec3(0.4, 0.45, 0.5) // Menos azul
#define FOG_COLOR vec3(0.8, 0.85, 0.9)  // Mais neutro

// Função de tonemapping ACES 
vec3 tonemapACES(vec3 x) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

// Função de iluminação global corrigida
vec3 applyGlobalIllumination(vec3 color, vec3 original) {
    // Iluminação baseada na cor original, não no céu
    float luminance = dot(original, vec3(0.299, 0.587, 0.114));
    
    // Bounced light mais neutra
    vec3 bouncedLight = vec3(0.5, 0.55, 0.6) * (luminance * 0.3 + 0.1);
    
    // Combinação mais suave
    return mix(color, color + bouncedLight, 0.2);
}

// Função de realce de cores vivas equilibrado
vec3 enhanceColors(vec3 color) {
    // Saturação equilibrada
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luminance), color, 1.3);
    
    // Balanceamento de canais - menos azul
    saturated.r = pow(saturated.r, 0.95);
    saturated.g = pow(saturated.g, 0.98);
    saturated.b = pow(saturated.b, 1.05); // Ainda realça azuis, mas menos
    
    return saturated;
}

// Função de efeito de luz solar melhorada
vec3 applySunLight(vec3 color, vec2 uv) {
    vec2 sunPos = vec2(0.8, 0.7);
    float sunDistance = distance(uv, sunPos);
    float sunIntensity = 1.0 - smoothstep(0.0, 0.4, sunDistance);
    
    // Glow mais quente e suave
    vec3 sunGlow = SUN_COLOR * pow(sunIntensity, 3.0) * 0.3;
    
    return color + sunGlow;
}

// Função de SSAO simplificado CORRIGIDA
float applySSAO(vec2 uv) {
    vec2 texelSize = 1.0 / vec2(HOOKED_size); // ⬅️ USAR HOOKED_size
    float occlusion = 0.0;
    float totalWeight = 0.0;

    // Amostras mais conservadoras
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;
            vec2 offset = vec2(x, y) * texelSize * 2.0;
            vec3 sampleColor = HOOKED_tex(uv + offset).rgb;
            float sampleLuma = dot(sampleColor, vec3(0.299, 0.587, 0.114));
            float currentLuma = dot(HOOKED_tex(uv).rgb, vec3(0.299, 0.587, 0.114));

            if(sampleLuma < currentLuma - 0.05) {
                occlusion += 0.08;
            }
            totalWeight += 1.0;
        }
    }

    return 1.0 - clamp(occlusion / totalWeight, 0.0, 0.2);
}

// Nova função para atmosfera sutil
vec3 applyAtmosphere(vec3 color, vec2 uv) {
    // Gradiente de céu muito suave
    float skyGradient = uv.y * 0.3 + 0.7;
    vec3 atmosphere = mix(vec3(0.9, 0.95, 1.0), vec3(0.6, 0.7, 0.8), skyGradient);
    
    // Aplica muito suavemente
    return mix(color, color * atmosphere, 0.1);
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Preserva cores originais primeiro
    vec3 baseColor = color;
    
    // 2. Aplica iluminação global muito suave
    #ifdef GLOBAL_ILLUMINATION
    color = applyGlobalIllumination(color, baseColor);
    #endif
    
    // 3. Realça cores equilibradamente
    color = enhanceColors(color);
    
    // 4. Aplica luz solar
    color = applySunLight(color, uv);
    
    // 5. Aplica SSAO muito suave
    float ssao = applySSAO(uv);
    color *= ssao;
    
    // 6. Aplica atmosfera sutil (sem névoa azul)
    color = applyAtmosphere(color, uv);
    
    // 7. Tonemapping para cores ricas
    #ifdef TONEMAP_ACES
    color = tonemapACES(color * 1.1);
    #endif
    
    // 8. Contraste final muito suave
    color = pow(color, vec3(1.05));
    
    // Garante cores naturais
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
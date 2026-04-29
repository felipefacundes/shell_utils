//!DESC Studio Ghibli Modern Style
//!HOOK MAIN
//!BIND HOOKED

#define POSTERIZATION_LEVELS 12.0
#define EDGE_THRESHOLD 0.08
#define SATURATION 1.3
#define CELL_SHADING_LEVELS 4.0
#define GHIBLI_BRIGHTNESS 1.15
#define SKIN_SMOOTHNESS 0.6
#define WATERCOLOR_EFFECT 0.3

// Função de noise
float my_random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Posterização suave - mais níveis para transições naturais
vec3 ghibliPosterize(vec3 color) {
    color = pow(color, vec3(0.95)); // Suaviza antes da posterização
    return floor(color * POSTERIZATION_LEVELS) / POSTERIZATION_LEVELS;
}

// Detecção de bordas suaves e seletivas
float ghibliEdgeDetection(vec2 uv) {
    vec2 texelSize = 1.0 / HOOKED_size;
    
    float center = dot(HOOKED_tex(uv).rgb, vec3(0.299, 0.587, 0.114));
    float left = dot(HOOKED_tex(uv + vec2(-texelSize.x * 1.5, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float right = dot(HOOKED_tex(uv + vec2(texelSize.x * 1.5, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float top = dot(HOOKED_tex(uv + vec2(0.0, -texelSize.y * 1.5)).rgb, vec3(0.299, 0.587, 0.114));
    float bottom = dot(HOOKED_tex(uv + vec2(0.0, texelSize.y * 1.5)).rgb, vec3(0.299, 0.587, 0.114));
    
    float gradient = max(abs(right - left), abs(bottom - top));
    
    // Suaviza a detecção de bordas
    return smoothstep(0.05, 0.2, gradient);
}

// Cel shading com transições suaves
vec3 ghibliCelShading(vec3 color, vec2 uv) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // 4 níveis com transições suaves
    float quantized;
    if (luminance > 0.75) quantized = 1.0;
    else if (luminance > 0.5) quantized = 0.75;
    else if (luminance > 0.25) quantized = 0.5;
    else quantized = 0.3;
    
    // Suaviza as transições
    float transition = smoothstep(0.2, 0.3, abs(luminance - quantized));
    quantized = mix(luminance, quantized, 0.7);
    
    return color * (quantized / max(luminance, 0.001));
}

// Saturação natural e orgânica
vec3 ghibliSaturation(vec3 color) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luminance), color, SATURATION);
    
    // Cores naturais - realça sem exageros
    saturated.r = pow(saturated.r, 0.92);  // Vermelhos suaves
    saturated.g = pow(saturated.g, 0.95);  // Verdes orgânicos
    saturated.b = pow(saturated.b, 0.98);  // Azuis naturais
    
    return saturated;
}

// Contornos suaves e orgânicos
vec3 ghibliOutline(vec3 color, float edge, vec2 uv) {
    // Contornos variáveis - mais fortes em bordas importantes
    float outlineStrength = edge * 0.7;
    
    // Contorno marrom escuro orgânico em vez de preto puro
    vec3 outlineColor = mix(color * 0.4, vec3(0.15, 0.1, 0.08), 0.6);
    
    return mix(color, outlineColor, outlineStrength);
}

// Suavização orgânica da pele
vec3 ghibliSkinSmoothing(vec3 color, vec2 uv) {
    // Detecta tons de pele de forma mais natural
    float skinMask = smoothstep(0.3, 0.7, color.r) * 
                    smoothstep(0.25, 0.6, color.g) * 
                    (1.0 - smoothstep(0.3, 0.6, color.b));
    
    if (skinMask > 0.3) {
        vec2 texelSize = 1.0 / HOOKED_size;
        
        // Blur orgânico e suave
        vec3 blur = vec3(0.0);
        float total = 0.0;
        
        for(int x = -1; x <= 1; x++) {
            for(int y = -1; y <= 1; y++) {
                vec2 offset = vec2(x, y) * texelSize;
                blur += HOOKED_tex(uv + offset).rgb;
                total += 1.0;
            }
        }
        blur /= total;
        
        return mix(color, blur, SKIN_SMOOTHNESS * skinMask);
    }
    
    return color;
}

// Realce de características naturais
vec3 ghibliFeatureEnhancement(vec3 color) {
    // Olhos - realce suave
    float eyeMask = smoothstep(0.4, 0.8, max(color.b, color.g) - color.r);
    if (eyeMask > 0.4) {
        color.rgb *= 1.2;
        color = mix(color, color * vec3(1.0, 1.1, 1.2), 0.3);
    }
    
    // Cabelo - realce orgânico
    float hairMask = smoothstep(0.5, 0.8, dot(color, vec3(0.299, 0.587, 0.114)));
    if (hairMask > 0.5 && eyeMask < 0.3) {
        color.rgb *= 1.15;
    }
    
    return color;
}

// Efeito aquarela suave
vec3 ghibliWatercolor(vec3 color, vec2 uv) {
    // Textura de aquarela muito sutil
    float watercolorNoise = my_random(uv * 300.0) * 0.1 + 0.95;
    
    // Variação de saturação sutil
    float saturationVariation = my_random(uv * 200.0) * 0.1 + 0.95;
    
    color *= watercolorNoise;
    
    // Aplica efeito aquarela seletivamente
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = mix(vec3(luminance), color, saturationVariation);
    
    return mix(color, desaturated, WATERCOLOR_EFFECT);
}

// Iluminação natural estilo Ghibli
vec3 ghibliLighting(vec3 color, vec2 uv) {
    // Iluminação suave com gradiente natural
    float verticalLight = pow(uv.y * 0.8 + 0.2, 0.5);
    color *= mix(0.9, 1.1, verticalLight);
    
    // Pequeno efeito de luz quente
    color = mix(color, color * vec3(1.02, 1.0, 0.98), 0.1);
    
    return color;
}

// Brilho natural
vec3 ghibliBrightness(vec3 color) {
    return color * GHIBLI_BRIGHTNESS;
}

// Processamento final - suavização geral
vec3 ghibliFinalTouch(vec3 color, vec2 uv) {
    // Suavização final muito leve
    vec2 texelSize = 1.0 / HOOKED_size;
    vec3 blur = HOOKED_tex(uv).rgb;
    blur += HOOKED_tex(uv + vec2(texelSize.x, 0.0)).rgb;
    blur += HOOKED_tex(uv + vec2(-texelSize.x, 0.0)).rgb;
    blur += HOOKED_tex(uv + vec2(0.0, texelSize.y)).rgb;
    blur += HOOKED_tex(uv + vec2(0.0, -texelSize.y)).rgb;
    blur /= 5.0;
    
    return mix(color, blur, 0.1);
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 1. Brilho Ghibli
    color = ghibliBrightness(color);
    
    // 2. Suavização de pele orgânica
    color = ghibliSkinSmoothing(color, uv);
    
    // 3. Realce de características naturais
    color = ghibliFeatureEnhancement(color);
    
    // 4. Posterização suave
    color = ghibliPosterize(color);
    
    // 5. Cel shading com transições suaves
    color = ghibliCelShading(color, uv);
    
    // 6. Saturação natural
    color = ghibliSaturation(color);
    
    // 7. Iluminação estilo Ghibli
    color = ghibliLighting(color, uv);
    
    // 8. Efeito aquarela
    color = ghibliWatercolor(color, uv);
    
    // 9. Detecção de bordas orgânicas
    float edge = ghibliEdgeDetection(uv);
    
    // 10. Contornos suaves
    color = ghibliOutline(color, edge, uv);
    
    // 11. Toque final
    color = ghibliFinalTouch(color, uv);
    
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
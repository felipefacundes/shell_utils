//!DESC Nature Mode TV Enhancement (Vibrant & Organic)
//!HOOK MAIN
//!BIND HOOKED

#define NATURE_COLORS
#define FOREST_ATMOSPHERE
#define WATER_ENHANCE
#define SKY_ENHANCE

// Parâmetros de natureza
#define FOREST_GREEN vec3(0.2, 0.6, 0.3)
#define SKY_BLUE vec3(0.4, 0.7, 0.9)
#define EARTH_BROWN vec3(0.5, 0.4, 0.3)
#define WATER_BLUE vec3(0.3, 0.6, 0.8)
#define SUNLIGHT vec3(1.0, 0.95, 0.8)

// Função para detectar verdes naturais
float isNaturalGreen(vec3 color) {
    float greenDominance = color.g - max(color.r, color.b);
    float saturation = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    return smoothstep(0.1, 0.4, greenDominance) * smoothstep(0.2, 0.5, saturation);
}

// Função para detectar azuis de céu/água
float isSkyWaterBlue(vec3 color) {
    float blueDominance = color.b - max(color.r, color.g);
    float brightness = dot(color, vec3(0.299, 0.587, 0.114));
    return smoothstep(0.1, 0.3, blueDominance) * smoothstep(0.3, 0.7, brightness);
}

// Função para realce de VERDES
vec3 enhanceGreens(vec3 color) {
    #ifdef NATURE_COLORS
    float greenMask = isNaturalGreen(color);
    
    if (greenMask > 0.1) {
        // Realce seletivo de verdes
        color.g = pow(color.g, 0.85); // Verdes mais intensos
        color.r *= 0.98; // Reduz vermelho para verdes mais puros
        color.b *= 0.95; // Reduz azul para verdes mais vivos
        
        // Aumenta saturação nos verdes
        float luminance = dot(color, vec3(0.299, 0.587, 0.114));
        vec3 saturated = mix(vec3(luminance), color, 1.6);
        color = mix(color, saturated, greenMask * 0.8);
    }
    #endif
    
    return color;
}

// Função para realce de AZUIS (céu/água)
vec3 enhanceBlues(vec3 color) {
    #if defined(WATER_ENHANCE) || defined(SKY_ENHANCE)
    float blueMask = isSkyWaterBlue(color);
    
    if (blueMask > 0.1) {
        // Azuis mais profundos e naturais
        color.b = pow(color.b, 0.9);
        color.g = pow(color.g, 0.95); // Mantém um toque de verde para naturalidade
        color.r *= 1.02; // Pequeno aquecimento
        
        // Saturação aumentada para azuis
        float luminance = dot(color, vec3(0.299, 0.587, 0.114));
        vec3 saturated = mix(vec3(luminance), color, 1.4);
        color = mix(color, saturated, blueMask * 0.6);
    }
    #endif
    
    return color;
}

// Função para realce de tons terrosos
vec3 enhanceEarthTones(vec3 color) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float brownMask = smoothstep(0.2, 0.5, color.r) * 
                     smoothstep(0.15, 0.4, color.g) * 
                     smoothstep(0.1, 0.3, color.b);
    
    if (brownMask > 0.2) {
        // Tons terrosos mais quentes e ricos
        color.r = pow(color.r, 0.92);
        color.g = pow(color.g, 0.94);
        color.b = pow(color.b, 1.05); // Azul levemente reduzido
        
        // Aumenta contraste em tons terrosos
        color = mix(color, color * 1.1, brownMask * 0.3);
    }
    
    return color;
}

// Função para atmosfera de floresta
vec3 applyForestAtmosphere(vec3 color, vec2 uv) {
    #ifdef FOREST_ATMOSPHERE
    // Simula luz filtrada por folhagem
    float forestDensity = (1.0 - uv.y) * 0.3;
    vec3 forestLight = mix(vec3(1.0), vec3(0.9, 1.0, 0.8), forestDensity);
    
    // Adiciona um leve tom verde atmosférico
    vec3 forestAtmosphere = mix(vec3(1.0), FOREST_GREEN * 0.1, forestDensity * 0.4);
    
    color = color * forestLight * forestAtmosphere;
    #endif
    
    return color;
}

// Função para luz solar natural
vec3 applyNaturalSunlight(vec3 color, vec2 uv) {
    // Posição do sol (canto superior)
    vec2 sunPos = vec2(0.8, 0.8);
    float sunDistance = distance(uv, sunPos);
    float sunIntensity = 1.0 - smoothstep(0.0, 0.4, sunDistance);
    
    // Luz solar quente e natural
    vec3 sunlight = SUNLIGHT * pow(sunIntensity, 3.0) * 0.2;
    
    return color + sunlight;
}

// Função para nitidez orgânica
vec3 applyOrganicSharpness(vec3 color) {
    // Sharpening suave para detalhes naturais
    vec3 sample1 = HOOKED_texOff(vec2(-1.0, -1.0)).rgb;
    vec3 sample2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 sample3 = HOOKED_texOff(vec2(1.0, -1.0)).rgb;
    vec3 sample4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 sample5 = HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    vec3 sample6 = HOOKED_texOff(vec2(-1.0, 1.0)).rgb;
    vec3 sample7 = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    vec3 sample8 = HOOKED_texOff(vec2(1.0, 1.0)).rgb;
    
    vec3 blur = (sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) / 8.0;
    vec3 edges = (color - blur) * 0.3;
    
    return color + edges;
}

// Função para contraste natural
vec3 applyNaturalContrast(vec3 color) {
    // Curva de contraste que preserva detalhes naturais
    color = pow(color, vec3(1.1));
    
    // Realce seletivo em tons médios (onde estão a maioria dos detalhes naturais)
    float midToneBoost = smoothstep(0.3, 0.7, dot(color, vec3(0.299, 0.587, 0.114)));
    color = mix(color, color * 1.05, midToneBoost * 0.2);
    
    return color;
}

// Função para vivacidade natural
vec3 applyNaturalVibrancy(vec3 color) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Saturação inteligente - mais forte em cores já saturadas
    float saturation = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    float saturationMask = smoothstep(0.1, 0.4, saturation);
    
    vec3 vibrant = mix(vec3(luminance), color, 1.3);
    return mix(color, vibrant, saturationMask * 0.6);
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Nitidez orgânica primeiro
    color = applyOrganicSharpness(color);
    
    // 2. Realce de VERDES (folhagem, plantas)
    color = enhanceGreens(color);
    
    // 3. Realce de AZUIS (céu, água)
    color = enhanceBlues(color);
    
    // 4. Realce de tons terrosos (terra, troncos)
    color = enhanceEarthTones(color);
    
    // 5. Vivacidade natural geral
    color = applyNaturalVibrancy(color);
    
    // 6. Atmosfera de floresta
    color = applyForestAtmosphere(color, uv);
    
    // 7. Luz solar natural
    color = applyNaturalSunlight(color, uv);
    
    // 8. Contraste natural
    color = applyNaturalContrast(color);
    
    // Garante cores naturais e equilibradas
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
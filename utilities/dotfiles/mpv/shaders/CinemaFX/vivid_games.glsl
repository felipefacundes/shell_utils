//!DESC Ultimate Game Mode Enhancement (Fixed)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define RESPONSE_BOOST 0.5
#define CLARITY_STRENGTH 0.7
#define COMPETITIVE_COLORS 1.25
#define DARK_BOOST 1.15
#define DETAIL_ENHANCE 0.4
#define CROSSHAIR_ENHANCE 0.2

// Função para redução de motion blur
vec3 applyResponseBoost(vec3 color, float strength) {
    // Sharpening controlado
    vec3 sample1 = HOOKED_texOff(vec2(-1.0, -1.0)).rgb * 0.5;
    vec3 sample2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb * 1.0;
    vec3 sample3 = HOOKED_texOff(vec2(1.0, -1.0)).rgb * 0.5;
    vec3 sample4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb * 1.0;
    vec3 sample5 = HOOKED_texOff(vec2(1.0, 0.0)).rgb * 1.0;
    vec3 sample6 = HOOKED_texOff(vec2(-1.0, 1.0)).rgb * 0.5;
    vec3 sample7 = HOOKED_texOff(vec2(0.0, 1.0)).rgb * 1.0;
    vec3 sample8 = HOOKED_texOff(vec2(1.0, 1.0)).rgb * 0.5;
    
    vec3 blur = (sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) / 6.0;
    vec3 edges = (color - blur) * strength;
    
    return color + edges;
}

// Função para cores competitivas CORRIGIDA
vec3 applyGameColors(vec3 color, float intensity) {
    // Detecção mais precisa de cores de jogo (vermelhos puros de HUD/inimigos)
    bool isPureRed = color.r > 0.8 && color.g < 0.3 && color.b < 0.3;
    bool isPureBlue = color.b > 0.8 && color.r < 0.3 && color.g < 0.3;
    bool isPureGreen = color.g > 0.8 && color.r < 0.3 && color.b < 0.3;
    
    if (isPureRed) {
        // Apenas vermelhos puros de UI/inimigos
        color.r = min(color.r * 1.2, 1.0);
    } else if (isPureBlue) {
        // Apenas azuis puros de aliados/HUD
        color.b = min(color.b * 1.15, 1.0);
    } else if (isPureGreen) {
        // Apenas verdes puros de HUD
        color.g = min(color.g * 1.15, 1.0);
    }
    
    // Saturação geral controlada
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, intensity);
}

// Função para melhoria de áreas escuras
vec3 applyDarkBoost(vec3 color, float boost) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Boost mais suave em áreas escuras
    if (luminance < 0.25) {
        float darkFactor = 1.0 - (luminance / 0.25);
        color = mix(color, color * boost, darkFactor * 0.3);
    }
    
    return color;
}

// Função para realce de detalhes textura
vec3 applyDetailEnhance(vec3 color, float strength) {
    vec3 dx = HOOKED_texOff(vec2(1.0, 0.0)).rgb - HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 dy = HOOKED_texOff(vec2(0.0, 1.0)).rgb - HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 detail = (dx * dx + dy * dy) * 0.5;
    
    return mix(color, color + detail, strength * 0.5);
}

// Função para melhoria de elementos de UI
vec3 applyUIEnhance(vec3 color, float strength) {
    // Detecta apenas cores muito puras de HUD
    float colorPurity = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    
    if (colorPurity > 0.9) {
        // Apenas cores muito puras e brilhantes
        float brightness = (color.r + color.g + color.b) / 3.0;
        if (brightness > 0.7) {
            color += (1.0 - color) * strength * 0.3;
        }
    }
    
    return color;
}

// Função de contraste otimizada
vec3 applyGameContrast(vec3 color) {
    // Curva de contraste mais natural
    color = pow(color, vec3(0.95));
    color = (color - 0.05) * 1.1;
    
    return clamp(color, 0.0, 1.0);
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // 1. Contraste suave
    vec3 contrastColor = applyGameContrast(color);
    
    // 2. Boost de resposta
    vec3 responsiveColor = applyResponseBoost(contrastColor, RESPONSE_BOOST);
    
    // 3. Melhoria de áreas escuras
    vec3 darkBoosted = applyDarkBoost(responsiveColor, DARK_BOOST);
    
    // 4. Cores competitivas (agora sem vazamento)
    vec3 gameColors = applyGameColors(darkBoosted, COMPETITIVE_COLORS);
    
    // 5. Realce de detalhes
    vec3 detailed = applyDetailEnhance(gameColors, DETAIL_ENHANCE);
    
    // 6. Melhoria de UI
    vec3 finalColor = applyUIEnhance(detailed, CROSSHAIR_ENHANCE);
    
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, originalColor.a);
}
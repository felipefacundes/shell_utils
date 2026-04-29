//!DESC Sports Mode TV Enhancement
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define MOTION_CLARITY 0.3
#define COLOR_VIVIDNESS 1.5
#define GREEN_BOOST 1.1
#define BLUE_BOOST 1.05
#define CONTRAST_BOOST 1.15
#define EDGE_ENHANCE 0.4

// Função para realce de bordas (melhor para acompanhar bolas e jogadores)
vec3 applyEdgeEnhancement(vec3 color, vec2 uv, float strength) {
    vec3 horizontal = HOOKED_texOff(vec2(1.0, 0.0)).rgb - HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 vertical = HOOKED_texOff(vec2(0.0, 1.0)).rgb - HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 edge = sqrt(horizontal * horizontal + vertical * vertical);
    
    return color + edge * strength;
}

// Função para cores mais vivas (especialmente verdes do campo)
vec3 applySportsColors(vec3 color, float vividness, float green_boost, float blue_boost) {
    // Boost seletivo em verdes (campos de futebol, gramados)
    float greenness = color.g - max(color.r, color.b);
    if (greenness > 0.1) {
        color.g *= green_boost;
    }
    
    // Boost em azuis (céu, uniformes)
    float blueness = color.b - max(color.r, color.g);
    if (blueness > 0.1) {
        color.b *= blue_boost;
    }
    
    // Saturação geral aumentada
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, vividness);
}

// Função para melhor contraste (destaque de jogadores)
vec3 applySportsContrast(vec3 color, float contrast) {
    color = pow(color, vec3(contrast));
    
    // Realce adicional nas médias frequências (onde estão os jogadores)
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float midToneBoost = smoothstep(0.3, 0.7, luminance);
    color += color * midToneBoost * 0.1;
    
    return color;
}

// Função para redução de motion blur (simulado)
vec3 applyMotionClarity(vec3 color, vec2 uv, float clarity) {
    // Amostras para "sharpening" temporal simulado
    vec3 sharp = color * 2.0;
    sharp -= HOOKED_texOff(vec2(0.5, 0.5)).rgb * 0.25;
    sharp -= HOOKED_texOff(vec2(-0.5, -0.5)).rgb * 0.25;
    sharp -= HOOKED_texOff(vec2(0.5, -0.5)).rgb * 0.25;
    sharp -= HOOKED_texOff(vec2(-0.5, 0.5)).rgb * 0.25;
    
    return mix(color, sharp, clarity);
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Aplica clareza de movimento primeiro
    vec3 clearColor = applyMotionClarity(color, uv, MOTION_CLARITY);
    
    // 2. Realce de bordas para melhor acompanhamento visual
    vec3 edgedColor = applyEdgeEnhancement(clearColor, uv, EDGE_ENHANCE);
    
    // 3. Contraste esportivo
    vec3 contrastColor = applySportsContrast(edgedColor, CONTRAST_BOOST);
    
    // 4. Cores vivas com boost em verdes e azuis
    vec3 finalColor = applySportsColors(contrastColor, COLOR_VIVIDNESS, GREEN_BOOST, BLUE_BOOST);
    
    // Garante que as cores não estourem
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, originalColor.a);
}
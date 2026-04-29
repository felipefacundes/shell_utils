//!DESC Ultimate Show & Event Mode (Balanced)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis - EQUILIBRADO
#define ENERGY_BOOST 1.15
#define COLOR_VIBRANCE 1.25
#define BRIGHTNESS 1.1
#define CONTRAST 1.05
#define SPARKLE_STRENGTH 0.04
#define DETAIL_ENHANCE 0.3

// Função para brilho controlado
vec3 applyEnergyBoost(vec3 color, float boost) {
    // Boost não-linear para evitar estouro
    color = 1.0 - exp(-color * boost);
    return color;
}

// Função para cores vibrantes sem estourar
vec3 applyShowColors(vec3 color, float intensity) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Saturação inteligente - preserva tons de pele
    float saturation = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    float saturationMask = smoothstep(0.2, 0.6, saturation);
    
    vec3 saturated = mix(vec3(luminance), color, intensity);
    color = mix(color, saturated, saturationMask * 0.6);
    
    return color;
}

// Função para contraste seguro
vec3 applyShowContrast(vec3 color, float strength) {
    // Curva S suave
    color = pow(color, vec3(0.95));
    color = (color - 0.03) * 1.06;
    
    return clamp(color, 0.0, 1.0);
}

// Função para sparkle controlado
vec3 applySparkleEffect(vec3 color, vec2 uv, float strength) {
    vec2 coord = uv * 6.0;
    float sparkle = sin(coord.x * 12.0) * cos(coord.y * 12.0);
    sparkle = abs(sparkle) * strength * 0.2;
    
    // Apenas em áreas específicas
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float sparkleMask = pow(luminance, 3.0) * 0.3;
    
    return min(color + vec3(sparkle) * sparkleMask, 1.0);
}

// Função para nitidez equilibrada
vec3 applyDetailEnhance(vec3 color, float strength) {
    vec3 sample1 = HOOKED_texOff(vec2(-1.0, -1.0)).rgb;
    vec3 sample2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 sample3 = HOOKED_texOff(vec2(1.0, -1.0)).rgb;
    vec3 sample4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 sample5 = HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    vec3 sample6 = HOOKED_texOff(vec2(-1.0, 1.0)).rgb;
    vec3 sample7 = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    vec3 sample8 = HOOKED_texOff(vec2(1.0, 1.0)).rgb;
    
    vec3 blur = (sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) / 8.0;
    
    // Sharpening apenas em bordas fortes
    vec3 edge = color - blur;
    float edgeStrength = length(edge);
    float edgeMask = smoothstep(0.05, 0.15, edgeStrength);
    
    return color + edge * strength * edgeMask;
}

// Função para luzes de palco seletivas
vec3 applyStageLights(vec3 color) {
    // Apenas cores muito saturadas e brilhantes
    float maxChannel = max(max(color.r, color.g), color.b);
    float minChannel = min(min(color.r, color.g), color.b);
    float purity = maxChannel - minChannel;
    
    if (purity > 0.7 && maxChannel > 0.5) {
        color = mix(color, color * 1.1, 0.4);
    }
    
    return color;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Brilho moderado
    vec3 brightColor = color * BRIGHTNESS;
    
    // 2. Energia controlada
    vec3 energized = applyEnergyBoost(brightColor, ENERGY_BOOST);
    
    // 3. Contraste seguro
    vec3 contrasted = applyShowContrast(energized, CONTRAST);
    
    // 4. Cores vibrantes sem estourar
    vec3 showColors = applyShowColors(contrasted, COLOR_VIBRANCE);
    
    // 5. Luzes de palco seletivas
    vec3 stageLights = applyStageLights(showColors);
    
    // 6. Nitidez equilibrada
    vec3 detailed = applyDetailEnhance(stageLights, DETAIL_ENHANCE);
    
    // 7. Sparkle sutil
    vec3 finalColor = applySparkleEffect(detailed, uv, SPARKLE_STRENGTH);
    
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, originalColor.a);
}
//!DESC Ultimate Show & Event Mode (Final Fixed)
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define ENERGY_BOOST 1.1
#define COLOR_VIBRANCE 1.2
#define DYNAMIC_CONTRAST 1.08
#define SPARKLE_STRENGTH 0.02
#define DETAIL_ENHANCE 0.3

// Função para cores vibrantes sem vazamento
vec3 applyShowColors(vec3 color, float intensity) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Saturação inteligente - apenas aumenta cores já saturadas
    float saturation = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    float saturationMask = smoothstep(0.1, 0.4, saturation);
    
    vec3 saturated = mix(vec3(luminance), color, intensity);
    saturated = mix(color, saturated, saturationMask * 0.5); // Aplica gradualmente
    
    return saturated;
}

// Função para contraste seguro
vec3 applyDynamicContrast(vec3 color, float strength) {
    // Curva muito suave
    color = pow(color, vec3(0.98));
    color = (color - 0.02) * 1.04;
    
    return clamp(color, 0.0, 1.0);
}

// Função para efeito sparkle muito sutil
vec3 applySparkleEffect(vec3 color, vec2 uv, float strength) {
    vec2 coord = uv * 3.0;
    float sparkle = sin(coord.x * 8.0) * cos(coord.y * 8.0);
    sparkle = abs(sparkle) * strength * 0.1;
    
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float sparkleMask = pow(luminance, 3.0) * 0.5; // Apenas em áreas muito brilhantes
    
    return color + vec3(sparkle) * sparkleMask;
}

// Função para nitidez sem halos
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
    
    // Apenas bordas fortes para evitar vazamento
    vec3 edge = abs(color - blur);
    float edgeStrength = length(edge);
    float edgeMask = smoothstep(0.05, 0.2, edgeStrength);
    
    vec3 sharpened = mix(color, color + (color - blur) * strength, edgeMask * 0.3);
    
    return sharpened;
}

// Função para realce seletivo de luzes
vec3 applyStageLights(vec3 color) {
    // Apenas cores muito puras e brilhantes (luzes de palco reais)
    float maxChannel = max(max(color.r, color.g), color.b);
    float minChannel = min(min(color.r, color.g), color.b);
    float purity = maxChannel - minChannel;
    
    // Apenas cores muito puras (>80% pureza) e brilhantes
    if (purity > 0.8 && maxChannel > 0.7) {
        color = mix(color, color * 1.05, 0.2); // Boost mínimo
    }
    
    return color;
}

// Função para brilho controlado
vec3 applyEnergyBoost(vec3 color, float boost) {
    // Boost não-linear que preserva altas luzes
    return 1.0 - exp(-color * boost);
}

// Função para atmosfera sutil
vec3 applyEventAtmosphere(vec3 color, vec2 uv) {
    vec2 centered = uv - 0.5;
    float vignette = 1.0 - dot(centered, centered) * 0.15;
    vignette = smoothstep(0.5, 1.0, vignette);
    
    return color * vignette;
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    vec2 uv = HOOKED_pos;
    
    // 1. Brilho controlado
    vec3 energized = applyEnergyBoost(color, ENERGY_BOOST);
    
    // 2. Contraste muito suave
    vec3 contrasted = applyDynamicContrast(energized, DYNAMIC_CONTRAST);
    
    // 3. Cores sem vazamento
    vec3 showColors = applyShowColors(contrasted, COLOR_VIBRANCE);
    
    // 4. Luzes de palco seletivas
    vec3 stageEnhanced = applyStageLights(showColors);
    
    // 5. Nitidez sem artefatos
    vec3 detailed = applyDetailEnhance(stageEnhanced, DETAIL_ENHANCE);
    
    // 6. Sparkle quase imperceptível
    vec3 sparkled = applySparkleEffect(detailed, uv, SPARKLE_STRENGTH);
    
    // 7. Atmosfera final
    vec3 finalColor = applyEventAtmosphere(sparkled, uv);
    
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, originalColor.a);
}
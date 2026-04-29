//!DESC Super Color Anaglyph 3D
//!HOOK MAIN
//!BIND HOOKED

#define PARALLAX_STRENGTH 0.015
#define COLOR_PRESERVATION 0.8
#define VIBRANCE_BOOST 1.5
#define BRIGHTNESS 1.1

// Método máximo de preservação de cores
vec3 superColorAnaglyph(vec3 leftColor, vec3 rightColor) {
    // Técnica que maximiza preservação de cores
    vec3 result;
    
    // Olho esquerdo (vermelho) - mantém MUITA cor
    result.r = leftColor.r * 0.7 + leftColor.g * 0.2 + leftColor.b * 0.1;
    
    // Olho direito (ciano) - mantém MUITA cor  
    result.g = rightColor.g * 0.6 + rightColor.r * 0.2 + rightColor.b * 0.2;
    result.b = rightColor.b * 0.6 + rightColor.r * 0.1 + rightColor.g * 0.3;
    
    // Overlap controlado para evitar fantasma
    result.g += leftColor.g * 0.3;
    result.b += leftColor.b * 0.3;
    result.r += rightColor.r * 0.2;
    
    return clamp(result, 0.0, 1.0);
}

// Realce de cores vibrantes
vec3 enhanceVibrance(vec3 color, float strength) {
    float maxChannel = max(max(color.r, color.g), color.b);
    float minChannel = min(min(color.r, color.g), color.b);
    float saturation = maxChannel - minChannel;
    
    // Boost seletivo em cores já saturadas
    float boost = smoothstep(0.1, 0.6, saturation) * strength;
    
    vec3 boosted = mix(vec3(dot(color, vec3(0.299, 0.587, 0.114))), color, 1.0 + boost);
    return mix(color, boosted, 0.5);
}

// Profundidade inteligente baseada em cores
float smartColorDepth(vec3 color, vec2 uv) {
    // Analisa tons de pele, céu, vegetação para profundidade natural
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Tons quentes (pele, madeira) mais próximos
    float warmth = color.r - color.b;
    float warmBoost = smoothstep(0.0, 0.3, warmth) * 0.3;
    
    // Tons frios (céu, água) mais distantes  
    float coolness = color.b - color.r;
    float coolReduce = smoothstep(0.0, 0.3, coolness) * 0.2;
    
    return (luminance + warmBoost - coolReduce) * 0.9;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // Profundidade inteligente
    float depth = smartColorDepth(color, uv);
    float parallax = PARALLAX_STRENGTH * (depth * 2.0 - 1.0);
    
    // Deslocamento para 3D
    vec2 leftUV = clamp(uv + vec2(-parallax, 0.0), 0.001, 0.999);
    vec2 rightUV = clamp(uv + vec2(parallax, 0.0), 0.001, 0.999);
    
    vec3 leftColor = HOOKED_tex(leftUV).rgb;
    vec3 rightColor = HOOKED_tex(rightUV).rgb;
    
    // Aplica anáglifo SUPER colorido
    vec3 anaglyphColor = superColorAnaglyph(leftColor, rightColor);
    
    // Realce de vibrância
    anaglyphColor = enhanceVibrance(anaglyphColor, VIBRANCE_BOOST);
    
    // Brilho ajustado
    anaglyphColor *= BRIGHTNESS;
    
    // Mistura final
    vec3 finalColor = mix(color, anaglyphColor, COLOR_PRESERVATION);
    
    return vec4(finalColor, originalColor.a);
}
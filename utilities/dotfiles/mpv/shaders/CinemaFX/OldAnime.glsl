//!DESC Authentic Japanese Anime Style
//!HOOK MAIN
//!BIND HOOKED

#define POSTERIZATION_LEVELS 5.0
#define EDGE_THRESHOLD 0.15
#define SATURATION 1.4
#define CELL_SHADING_LEVELS 3.0
#define ANIME_BRIGHTNESS 1.1
#define SKIN_SMOOTHNESS 0.8

// Função de noise
float my_random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Posterização estilo anime
vec3 animePosterize(vec3 color) {
    return floor(color * POSTERIZATION_LEVELS) / POSTERIZATION_LEVELS;
}

// Detecção de bordas forte para contornos marcantes
float animeEdgeDetection(vec2 uv) {
    vec2 texelSize = 1.0 / HOOKED_size;
    
    // Amostras para bordas mais largas
    float center = dot(HOOKED_tex(uv).rgb, vec3(0.299, 0.587, 0.114));
    float left = dot(HOOKED_tex(uv + vec2(-texelSize.x * 2.0, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float right = dot(HOOKED_tex(uv + vec2(texelSize.x * 2.0, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float top = dot(HOOKED_tex(uv + vec2(0.0, -texelSize.y * 2.0)).rgb, vec3(0.299, 0.587, 0.114));
    float bottom = dot(HOOKED_tex(uv + vec2(0.0, texelSize.y * 2.0)).rgb, vec3(0.299, 0.587, 0.114));
    
    float gradient = max(abs(right - left), abs(bottom - top));
    return gradient;
}

// Cel shading autêntico com poucos níveis
vec3 animeCelShading(vec3 color) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Apenas 3 níveis como nos animes clássicos
    float quantized;
    if (luminance > 0.7) quantized = 1.0;
    else if (luminance > 0.3) quantized = 0.5;
    else quantized = 0.2;
    
    return color * (quantized / max(luminance, 0.001));
}

// Saturação estilo anime
vec3 animeSaturation(vec3 color) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luminance), color, SATURATION);
    
    // Boost em cores específicas do anime
    saturated.r = pow(saturated.r, 0.85);  // Vermelhos intensos
    saturated.b = pow(saturated.b, 1.1);   // Azuis vibrantes
    
    return saturated;
}

// Contornos pretos marcantes
vec3 animeOutline(vec3 color, float edge) {
    float outline = smoothstep(EDGE_THRESHOLD - 0.05, EDGE_THRESHOLD + 0.05, edge);
    
    // Contorno preto puro e forte
    return mix(color, vec3(0.0, 0.0, 0.0), outline * 0.9);
}

// Suavização de pele estilo anime
vec3 animeSkinSmoothing(vec3 color, vec2 uv) {
    // Detecta tons de pele
    float skinMask = smoothstep(0.4, 0.8, color.r) * 
                    smoothstep(0.3, 0.7, color.g) * 
                    (1.0 - smoothstep(0.4, 0.7, color.b));
    
    if (skinMask > 0.5) {
        vec2 texelSize = 1.0 / HOOKED_size;
        
        // Blur forte apenas na pele
        vec3 blur = vec3(0.0);
        float total = 0.0;
        
        for(int x = -2; x <= 2; x++) {
            for(int y = -2; y <= 2; y++) {
                vec2 offset = vec2(x, y) * texelSize * 2.0;
                blur += HOOKED_tex(uv + offset).rgb;
                total += 1.0;
            }
        }
        blur /= total;
        
        return mix(color, blur, SKIN_SMOOTHNESS * skinMask);
    }
    
    return color;
}

// Realce de olhos e cabelo
vec3 animeFeatureEnhancement(vec3 color) {
    // Olhos azuis/verdes vibrantes
    float eyeMask = smoothstep(0.5, 0.9, color.b - max(color.r, color.g));
    if (eyeMask > 0.3) {
        color.b = pow(color.b, 0.7);
        color.rgb *= 1.3;
    }
    
    // Cabelo colorido vibrante
    float hairMask = max(
        smoothstep(0.6, 0.9, color.r - max(color.g, color.b)), // Cabelo vermelho/laranja
        smoothstep(0.5, 0.8, color.b - max(color.r, color.g))  // Cabelo azul/roxo
    );
    
    if (hairMask > 0.4) {
        color.rgb *= 1.4;
    }
    
    return color;
}

// Efeito de sombreamento anime
vec3 animeShading(vec3 color, vec2 uv) {
    // Sombreamento vertical suave (luz vindo de cima)
    float verticalShading = pow(uv.y, 0.3);
    color *= mix(0.8, 1.2, verticalShading);
    
    return color;
}

// Brilho geral ajustado
vec3 animeBrightness(vec3 color) {
    return color * ANIME_BRIGHTNESS;
}

// Textura de pintura digital
vec3 animeTexture(vec3 color, vec2 uv) {
    // Textura muito sutil de pintura
    float grain = my_random(uv * 1000.0) * 0.02 + 0.99;
    return color * grain;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 1. Suavização de pele (primeiro para melhor resultado)
    color = animeSkinSmoothing(color, uv);
    
    // 2. Brilho anime
    color = animeBrightness(color);
    
    // 3. Realce de características
    color = animeFeatureEnhancement(color);
    
    // 4. Posterização
    color = animePosterize(color);
    
    // 5. Cel shading autêntico
    color = animeCelShading(color);
    
    // 6. Saturação anime
    color = animeSaturation(color);
    
    // 7. Sombreamento estilo anime
    color = animeShading(color, uv);
    
    // 8. Detecção de bordas fortes
    float edge = animeEdgeDetection(uv);
    
    // 9. Contornos pretos marcantes
    color = animeOutline(color, edge);
    
    // 10. Textura final
    color = animeTexture(color, uv);
    
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
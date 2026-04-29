//!DESC Modern Cartoon Effect
//!HOOK MAIN
//!BIND HOOKED

#define POSTERIZATION_LEVELS 8.0
#define EDGE_THRESHOLD 0.1
#define SATURATION 1.3
#define CELL_SHADING 0.4
#define SMOOTHNESS 0.2

// Função de noise para textura
float my_random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Posterização - reduz cores para efeito cartoon
vec3 posterize(vec3 color, float levels) {
    return floor(color * levels) / levels;
}

// Detecção de bordas por diferença de cores
float edgeDetection(vec2 uv) {
    vec2 texelSize = 1.0 / HOOKED_size;
    
    // Amostras para detecção de bordas
    float center = dot(HOOKED_tex(uv).rgb, vec3(0.299, 0.587, 0.114));
    float left = dot(HOOKED_tex(uv + vec2(-texelSize.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float right = dot(HOOKED_tex(uv + vec2(texelSize.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float top = dot(HOOKED_tex(uv + vec2(0.0, -texelSize.y)).rgb, vec3(0.299, 0.587, 0.114));
    float bottom = dot(HOOKED_tex(uv + vec2(0.0, texelSize.y)).rgb, vec3(0.299, 0.587, 0.114));
    
    // Gradiente horizontal e vertical
    float gradientX = abs(right - left);
    float gradientY = abs(bottom - top);
    
    return max(gradientX, gradientY);
}

// Cel shading - cria áreas de sombra planas
vec3 celShading(vec3 color, vec2 uv) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Quantização da luminância para criar áreas planas
    float steps = 4.0;
    float quantized = floor(luminance * steps) / steps;
    
    // Suaviza as transições
    quantized = mix(luminance, quantized, CELL_SHADING);
    
    // Ajusta a cor baseada na luminância quantizada
    return color * (quantized / max(luminance, 0.001));
}

// Aumento de saturação para cores vibrantes
vec3 enhanceSaturation(vec3 color, float saturation) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, saturation);
}

// Efeito de contorno suave
vec3 smoothOutline(vec3 color, float edge, vec2 uv) {
    // Suaviza as bordas detectadas
    float smoothEdge = smoothstep(EDGE_THRESHOLD - 0.05, EDGE_THRESHOLD + 0.05, edge);
    
    // Aplica contorno preto suave
    vec3 outlineColor = mix(color, vec3(0.0, 0.0, 0.0), smoothEdge * 0.8);
    
    return outlineColor;
}

// Textura de papel/desenho sutil
vec3 paperTexture(vec3 color, vec2 uv) {
    // Adiciona uma textura sutil de papel
    float textureNoise = my_random(uv * 500.0) * 0.1 + 0.95;
    return color * textureNoise;
}

// Realce de cores específicas para pele e cabelo
vec3 enhanceSkinAndHair(vec3 color) {
    // Detecta tons de pele (vermelho/laranja)
    float skinMask = smoothstep(0.3, 0.6, color.r) * 
                    smoothstep(0.2, 0.5, color.g) * 
                    smoothstep(0.1, 0.4, color.b);
    
    // Detecta tons de cabelo (marrom/preto)
    float hairMask = smoothstep(0.0, 0.3, dot(color, vec3(0.299, 0.587, 0.114)));
    
    if (skinMask > 0.5) {
        // Realça tons de pele - mais quente e suave
        color.r = pow(color.r, 0.9);
        color.g = pow(color.g, 0.95);
        color.b = pow(color.b, 1.1);
    } else if (hairMask > 0.7) {
        // Escurece tons de cabelo para mais contraste
        color *= 0.8;
    }
    
    return color;
}

// Efeito de desfoque suave para reduzir detalhes realistas
vec3 subtleBlur(vec3 color, vec2 uv) {
    vec2 texelSize = 1.0 / HOOKED_size;
    
    // Amostras para blur suave
    vec3 sample1 = HOOKED_tex(uv + vec2(-texelSize.x, -texelSize.y)).rgb;
    vec3 sample2 = HOOKED_tex(uv + vec2(0.0, -texelSize.y)).rgb;
    vec3 sample3 = HOOKED_tex(uv + vec2(texelSize.x, -texelSize.y)).rgb;
    vec3 sample4 = HOOKED_tex(uv + vec2(-texelSize.x, 0.0)).rgb;
    vec3 sample5 = HOOKED_tex(uv + vec2(texelSize.x, 0.0)).rgb;
    vec3 sample6 = HOOKED_tex(uv + vec2(-texelSize.x, texelSize.y)).rgb;
    vec3 sample7 = HOOKED_tex(uv + vec2(0.0, texelSize.y)).rgb;
    vec3 sample8 = HOOKED_tex(uv + vec2(texelSize.x, texelSize.y)).rgb;
    
    vec3 blur = (sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) / 8.0;
    
    // Mistura suave com o blur
    return mix(color, blur, SMOOTHNESS);
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 1. Desfoque suave para reduzir detalhes realistas
    color = subtleBlur(color, uv);
    
    // 2. Realce de tons de pele e cabelo
    color = enhanceSkinAndHair(color);
    
    // 3. Posterização das cores
    color = posterize(color, POSTERIZATION_LEVELS);
    
    // 4. Cel shading para áreas planas de cor
    color = celShading(color, uv);
    
    // 5. Saturação aumentada para cores vibrantes
    color = enhanceSaturation(color, SATURATION);
    
    // 6. Detecção de bordas
    float edge = edgeDetection(uv);
    
    // 7. Aplicação de contornos
    color = smoothOutline(color, edge, uv);
    
    // 8. Textura de papel sutil
    color = paperTexture(color, uv);
    
    // 9. Contraste final
    color = pow(color, vec3(1.1));
    
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
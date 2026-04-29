//!DESC Happy Modern Cartoon Effect
//!HOOK MAIN
//!BIND HOOKED

#define POSTERIZATION_LEVELS 6.0
#define EDGE_THRESHOLD 0.08
#define SATURATION 1.6
#define CELL_SHADING 0.3
#define BRIGHTNESS_BOOST 1.2
#define COLOR_VIBRANCE 1.4

// Função de noise para textura
float my_random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Posterização suave para cores alegres
vec3 posterize(vec3 color, float levels) {
    color = pow(color, vec3(0.9)); // Clareia antes da posterização
    return floor(color * levels) / levels;
}

// Detecção de bordas finas e suaves
float edgeDetection(vec2 uv) {
    vec2 texelSize = 1.0 / HOOKED_size;
    
    float center = dot(HOOKED_tex(uv).rgb, vec3(0.299, 0.587, 0.114));
    float left = dot(HOOKED_tex(uv + vec2(-texelSize.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float right = dot(HOOKED_tex(uv + vec2(texelSize.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float top = dot(HOOKED_tex(uv + vec2(0.0, -texelSize.y)).rgb, vec3(0.299, 0.587, 0.114));
    float bottom = dot(HOOKED_tex(uv + vec2(0.0, texelSize.y)).rgb, vec3(0.299, 0.587, 0.114));
    
    float gradientX = abs(right - left);
    float gradientY = abs(bottom - top);
    
    return max(gradientX, gradientY);
}

// Cel shading suave com mais níveis de luz
vec3 celShading(vec3 color, vec2 uv) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Mais níveis para transições suaves
    float steps = 3.0; // Menos níveis = mais plano, mas mantemos suave
    float quantized = floor(luminance * steps) / steps;
    
    // Transição muito suave entre tons
    quantized = mix(luminance, quantized, CELL_SHADING);
    
    // Clareia as sombras
    quantized = pow(quantized, 0.8);
    
    return color * (quantized / max(luminance, 0.001));
}

// Saturação vibrante e alegre
vec3 enhanceSaturation(vec3 color, float saturation) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luminance), color, saturation);
    
    // Boost extra em cores já saturadas
    float colorfulness = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    float boostMask = smoothstep(0.2, 0.6, colorfulness);
    
    return mix(saturated, saturated * 1.1, boostMask * 0.3);
}

// Contornos coloridos e suaves no estilo moderno
vec3 happyOutline(vec3 color, float edge, vec2 uv) {
    float smoothEdge = smoothstep(EDGE_THRESHOLD - 0.03, EDGE_THRESHOLD + 0.03, edge);
    
    // Em vez de preto, usa contornos escuros mas coloridos
    vec3 outlineColor = color * 0.6; // Escurece a cor original
    outlineColor = mix(outlineColor, vec3(0.1, 0.1, 0.2), 0.3); // Azul escuro suave
    
    return mix(color, outlineColor, smoothEdge * 0.6); // Contornos mais sutis
}

// Textura de desenho digital limpo
vec3 digitalTexture(vec3 color, vec2 uv) {
    // Textura muito sutil - quase imperceptível
    float textureNoise = my_random(uv * 800.0) * 0.03 + 0.985;
    return color * textureNoise;
}

// Realce de cores para pele saudável e cabelo vibrante
vec3 enhanceHappyColors(vec3 color) {
    // Detecta tons de pele (mais amplo para pele mais clara)
    float skinMask = smoothstep(0.4, 0.8, color.r) * 
                    smoothstep(0.3, 0.7, color.g) * 
                    smoothstep(0.2, 0.6, color.b);
    
    // Detecta tons quentes (vermelhos, laranjas)
    float warmMask = smoothstep(0.5, 0.9, color.r - max(color.g, color.b));
    
    if (skinMask > 0.3) {
        // Pele mais clara e saudável
        color.r = pow(color.r, 0.85); // Vermelho suavizado
        color.g = pow(color.g, 0.9);  // Verde mantido
        color.b = pow(color.b, 0.95); // Azul quase neutro
        color *= 1.1; // Clareia a pele
    } 
    
    if (warmMask > 0.5) {
        // Cores quentes mais vibrantes
        color.rgb *= 1.15;
    }
    
    return color;
}

// Brilho geral aumentado
vec3 boostBrightness(vec3 color) {
    return color * BRIGHTNESS_BOOST;
}

// Efeito de desfoque mínimo para suavizar
vec3 minimalBlur(vec3 color, vec2 uv) {
    vec2 texelSize = 1.0 / HOOKED_size;
    
    // Apenas 4 amostras para blur muito suave
    vec3 sample1 = HOOKED_tex(uv + vec2(-texelSize.x, 0.0)).rgb;
    vec3 sample2 = HOOKED_tex(uv + vec2(texelSize.x, 0.0)).rgb;
    vec3 sample3 = HOOKED_tex(uv + vec2(0.0, -texelSize.y)).rgb;
    vec3 sample4 = HOOKED_tex(uv + vec2(0.0, texelSize.y)).rgb;
    
    vec3 blur = (color + sample1 + sample2 + sample3 + sample4) / 5.0;
    
    // Mistura mínima
    return mix(color, blur, 0.1);
}

// Vibrância extra para cores modernas
vec3 applyVibrance(vec3 color) {
    float maxChannel = max(max(color.r, color.g), color.b);
    float minChannel = min(min(color.r, color.g), color.b);
    float saturation = maxChannel - minChannel;
    
    // Boost seletivo em cores médias
    float vibranceMask = smoothstep(0.1, 0.4, saturation);
    vec3 vibrant = mix(vec3(dot(color, vec3(0.299, 0.587, 0.114))), color, COLOR_VIBRANCE);
    
    return mix(color, vibrant, vibranceMask * 0.5);
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 1. Brilho geral aumentado primeiro
    color = boostBrightness(color);
    
    // 2. Desfoque mínimo
    color = minimalBlur(color, uv);
    
    // 3. Cores felizes e saudáveis
    color = enhanceHappyColors(color);
    
    // 4. Posterização alegre
    color = posterize(color, POSTERIZATION_LEVELS);
    
    // 5. Cel shading suave
    color = celShading(color, uv);
    
    // 6. Saturação vibrante
    color = enhanceSaturation(color, SATURATION);
    
    // 7. Vibrância extra
    color = applyVibrance(color);
    
    // 8. Detecção de bordas suaves
    float edge = edgeDetection(uv);
    
    // 9. Contornos coloridos e felizes
    color = happyOutline(color, edge, uv);
    
    // 10. Textura digital limpa
    color = digitalTexture(color, uv);
    
    // 11. Contraste moderno (não muito forte)
    color = pow(color, vec3(1.05));
    
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
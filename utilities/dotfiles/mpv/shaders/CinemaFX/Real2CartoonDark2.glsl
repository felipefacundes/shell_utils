//!DESC Anime Style - Edge Detection
//!HOOK MAIN
//!BIND HOOKED
//!SAVE EDGES
//!COMPONENTS 1

// Parâmetros de detecção de borda
#define EDGE_THRESHOLD 0.3
#define EDGE_STRENGTH 1.2

float get_luma(vec4 rgba) {
    return dot(vec3(0.299, 0.587, 0.114), rgba.rgb);
}

vec4 hook() {
    float luma_center = get_luma(HOOKED_tex(HOOKED_pos));
    
    // Operador Sobel para detecção de bordas
    float gx = 0.0;
    float gy = 0.0;
    
    // Gradiente X
    gx += get_luma(HOOKED_texOff(vec2(-1.0, -1.0))) * -1.0;
    gx += get_luma(HOOKED_texOff(vec2(-1.0,  0.0))) * -2.0;
    gx += get_luma(HOOKED_texOff(vec2(-1.0,  1.0))) * -1.0;
    gx += get_luma(HOOKED_texOff(vec2( 1.0, -1.0))) *  1.0;
    gx += get_luma(HOOKED_texOff(vec2( 1.0,  0.0))) *  2.0;
    gx += get_luma(HOOKED_texOff(vec2( 1.0,  1.0))) *  1.0;
    
    // Gradiente Y
    gy += get_luma(HOOKED_texOff(vec2(-1.0, -1.0))) * -1.0;
    gy += get_luma(HOOKED_texOff(vec2( 0.0, -1.0))) * -2.0;
    gy += get_luma(HOOKED_texOff(vec2( 1.0, -1.0))) * -1.0;
    gy += get_luma(HOOKED_texOff(vec2(-1.0,  1.0))) *  1.0;
    gy += get_luma(HOOKED_texOff(vec2( 0.0,  1.0))) *  2.0;
    gy += get_luma(HOOKED_texOff(vec2( 1.0,  1.0))) *  1.0;
    
    float edge = sqrt(gx * gx + gy * gy);
    edge = smoothstep(EDGE_THRESHOLD, EDGE_THRESHOLD + 0.1, edge) * EDGE_STRENGTH;
    
    return vec4(edge, 0.0, 0.0, 1.0);
}

//!DESC Anime Style - Posterize and Saturate
//!HOOK MAIN
//!BIND HOOKED
//!SAVE POSTERIZED
//!COMPONENTS 4

// Parâmetros de posterização e saturação
#define COLOR_LEVELS 6.0      // Número de níveis de cor (mais baixo = mais estilizado)
#define SATURATION 1.5        // Saturação aumentada
#define BRIGHTNESS 1.05       // Leve aumento de brilho

// Converte RGB para HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Converte HSV para RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    
    // Posterização (reduz níveis de cor)
    vec3 posterized;
    posterized.r = floor(color.r * COLOR_LEVELS + 0.5) / COLOR_LEVELS;
    posterized.g = floor(color.g * COLOR_LEVELS + 0.5) / COLOR_LEVELS;
    posterized.b = floor(color.b * COLOR_LEVELS + 0.5) / COLOR_LEVELS;
    
    // Aumenta saturação
    vec3 hsv = rgb2hsv(posterized);
    hsv.y = clamp(hsv.y * SATURATION, 0.0, 1.0);
    hsv.z = hsv.z * BRIGHTNESS;
    vec3 saturated = hsv2rgb(hsv);
    
    return vec4(saturated, color.a);
}

//!DESC Anime Style - Shadow Enhancement
//!HOOK MAIN
//!BIND HOOKED
//!BIND POSTERIZED
//!SAVE SHADOWED
//!COMPONENTS 4

// Parâmetros de sombra
#define SHADOW_STRENGTH 0.4
#define SHADOW_THRESHOLD 0.4

float get_luma(vec4 rgba) {
    return dot(vec3(0.299, 0.587, 0.114), rgba.rgb);
}

vec4 hook() {
    vec4 color = POSTERIZED_tex(HOOKED_pos);
    float luma = get_luma(color);
    
    // Realça sombras para look mais anime
    if (luma < SHADOW_THRESHOLD) {
        float shadow_factor = 1.0 - (luma / SHADOW_THRESHOLD);
        vec3 darkened = color.rgb * (1.0 - shadow_factor * SHADOW_STRENGTH);
        
        // Adiciona leve tom azulado nas sombras (comum em anime)
        darkened = mix(darkened, darkened * vec3(0.9, 0.95, 1.1), shadow_factor * 0.3);
        
        return vec4(darkened, color.a);
    }
    
    // Realça highlights
    if (luma > 0.7) {
        float highlight_factor = (luma - 0.7) / 0.3;
        vec3 brightened = color.rgb * (1.0 + highlight_factor * 0.15);
        return vec4(brightened, color.a);
    }
    
    return color;
}

//!DESC Anime Style - Apply Edges and Final
//!HOOK MAIN
//!BIND HOOKED
//!BIND EDGES
//!BIND SHADOWED

// Parâmetros de linha
#define LINE_COLOR vec3(0.05, 0.05, 0.1)  // Cor das linhas (quase preto com leve azul)
#define LINE_THICKNESS 1.0

vec4 hook() {
    vec4 color = SHADOWED_tex(HOOKED_pos);
    float edge = EDGES_tex(HOOKED_pos).r;
    
    // Aplica as bordas estilo anime
    vec3 final_color = mix(color.rgb, LINE_COLOR, edge * LINE_THICKNESS);
    
    // Leve sharpen final para clareza
    vec4 center = vec4(final_color, color.a);
    vec4 blurred = (
        SHADOWED_texOff(vec2(-1.0, 0.0)) +
        SHADOWED_texOff(vec2( 1.0, 0.0)) +
        SHADOWED_texOff(vec2( 0.0,-1.0)) +
        SHADOWED_texOff(vec2( 0.0, 1.0))
    ) * 0.25;
    
    vec3 sharpened = final_color + (final_color - blurred.rgb) * 0.3;
    
    return vec4(sharpened, color.a);
}
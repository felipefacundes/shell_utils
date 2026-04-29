//!DESC Anaglyph 3D Effect - Red-Cyan
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros do efeito 3D
#define DEPTH_STRENGTH 3.0      // Intensidade da separação 3D (1.0 - 10.0)
#define USE_OPTIMIZED_COLORS 1  // 1 = cores otimizadas, 0 = método clássico
#define DEPTH_MODE 1            // 0 = uniforme, 1 = baseado em luminância, 2 = baseado em bordas

// Deslocamento em pixels (ajustado pela resolução)
#define PIXEL_OFFSET (DEPTH_STRENGTH * HOOKED_pt.x)

float get_luma(vec3 rgb) {
    return dot(rgb, vec3(0.299, 0.587, 0.114));
}

// Detecta profundidade baseada em luminância
float compute_depth_luma(vec2 pos) {
    vec3 color = HOOKED_tex(pos).rgb;
    float luma = get_luma(color);
    
    // Objetos mais claros = mais próximos
    return luma;
}

// Detecta profundidade baseada em bordas (mais contraste = mais próximo)
float compute_depth_edges(vec2 pos) {
    float center = get_luma(HOOKED_tex(pos).rgb);
    
    float edge = 0.0;
    edge += abs(center - get_luma(HOOKED_texOff(vec2(-1.0, 0.0)).rgb));
    edge += abs(center - get_luma(HOOKED_texOff(vec2( 1.0, 0.0)).rgb));
    edge += abs(center - get_luma(HOOKED_texOff(vec2( 0.0,-1.0)).rgb));
    edge += abs(center - get_luma(HOOKED_texOff(vec2( 0.0, 1.0)).rgb));
    
    return edge * 2.0;
}

vec4 hook() {
    vec2 pos = HOOKED_pos;
    
    // Calcula profundidade baseada no modo escolhido
    float depth = 0.5; // Profundidade padrão (uniforme)
    
    if (DEPTH_MODE == 1) {
        depth = compute_depth_luma(pos);
    } else if (DEPTH_MODE == 2) {
        depth = compute_depth_edges(pos);
        depth = clamp(depth, 0.0, 1.0);
    }
    
    // Calcula offset baseado na profundidade
    // Objetos mais próximos (depth alto) = maior separação
    float offset = PIXEL_OFFSET * (depth - 0.5);
    
    // Amostra as cores com deslocamento
    vec3 color_left = HOOKED_tex(pos - vec2(offset, 0.0)).rgb;   // Canal vermelho (olho esquerdo)
    vec3 color_right = HOOKED_tex(pos + vec2(offset, 0.0)).rgb;  // Canal ciano (olho direito)
    
    vec3 final_color;
    
    if (USE_OPTIMIZED_COLORS == 1) {
        // Método otimizado (Dubois) - melhor separação de cores e menos ghosting
        // Olho esquerdo (vermelho)
        float left_r = color_left.r * 0.4561 + color_left.g * 0.5008 + color_left.b * 0.1766;
        
        // Olho direito (ciano)
        float right_g = color_right.r * -0.0434 + color_right.g * 0.3785 + color_right.b * -0.0721;
        float right_b = color_right.r * -0.0879 + color_right.g * 0.7338 + color_right.b * 0.1128;
        
        final_color = vec3(left_r, right_g, right_b);
        
    } else {
        // Método clássico - mais simples mas com mais ghosting
        final_color = vec3(color_left.r, color_right.g, color_right.b);
    }
    
    // Aumenta levemente o contraste para melhorar a percepção 3D
    final_color = (final_color - 0.5) * 1.1 + 0.5;
    final_color = clamp(final_color, 0.0, 1.0);
    
    return vec4(final_color, 1.0);
}

//!DESC Anaglyph 3D - Optional Depth Enhancement
//!HOOK MAIN
//!BIND HOOKED

// Ative este pass adicional se quiser mais profundidade
// Para ativar, descomente esta seção e ajuste ENHANCE_DEPTH

#define ENHANCE_DEPTH 0  // 0 = desativado, 1 = ativado

vec4 hook() {
    if (ENHANCE_DEPTH == 0) {
        return HOOKED_tex(HOOKED_pos);
    }
    
    vec4 color = HOOKED_tex(HOOKED_pos);
    
    // Aumenta contraste para melhorar percepção de profundidade
    vec3 enhanced = (color.rgb - 0.5) * 1.15 + 0.5;
    
    // Leve sharpen para clareza
    vec3 blurred = (
        HOOKED_texOff(vec2(-1.0, 0.0)).rgb +
        HOOKED_texOff(vec2( 1.0, 0.0)).rgb +
        HOOKED_texOff(vec2( 0.0,-1.0)).rgb +
        HOOKED_texOff(vec2( 0.0, 1.0)).rgb
    ) * 0.25;
    
    enhanced = enhanced + (enhanced - blurred) * 0.2;
    enhanced = clamp(enhanced, 0.0, 1.0);
    
    return vec4(enhanced, color.a);
}
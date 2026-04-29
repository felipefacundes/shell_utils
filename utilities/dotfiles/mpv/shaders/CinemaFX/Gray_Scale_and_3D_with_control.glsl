//!DESC Advanced Anaglyph 3D with Depth Map
//!HOOK MAIN
//!BIND HOOKED

#define PARALLAX_STRENGTH 0.015
#define DEPTH_INTENSITY 1.0
#define COLOR_MODE 1 // 1=Red/Cyan, 2=Amber/Blue, 3=Magenta/Green
#define GHOSTING_REDUCTION 0.5

// Mapeamento de profundidade mais sofisticado
float advancedDepthMap(vec3 color, vec2 uv) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Adiciona padrão baseado na posição para teste
    float pattern = sin(uv.x * 10.0) * 0.1 + sin(uv.y * 8.0) * 0.1;
    
    // Combina luminância com padrão para profundidade variada
    return (luminance + pattern * 0.3) * DEPTH_INTENSITY;
}

// Redução de ghosting (fantasmas)
vec3 reduceGhosting(vec3 leftColor, vec3 rightColor) {
    // Remove sobreposição excessiva de cores
    float similarity = dot(normalize(leftColor), normalize(rightColor));
    float blendFactor = smoothstep(0.8, 1.0, similarity);
    
    return mix(leftColor, leftColor * 0.7 + rightColor * 0.3, blendFactor * GHOSTING_REDUCTION);
}

// Diferentes modos de anáglifo
vec3 anaglyphByMode(vec3 leftColor, vec3 rightColor, int mode) {
    if(mode == 1) {
        // Vermelho/Ciano (clássico)
        return vec3(dot(leftColor, vec3(0.299, 0.587, 0.114)),
                   dot(rightColor, vec3(0.299, 0.587, 0.114)),
                   dot(rightColor, vec3(0.299, 0.587, 0.114)));
    }
    else if(mode == 2) {
        // Âmbar/Azul
        return vec3(dot(leftColor, vec3(0.5, 0.4, 0.1)),
                   dot(leftColor, vec3(0.5, 0.4, 0.1)) * 0.5,
                   dot(rightColor, vec3(0.1, 0.3, 0.6)));
    }
    else if(mode == 3) {
        // Magenta/Verde
        return vec3(dot(leftColor, vec3(0.7, 0.0, 0.7)),
                   dot(rightColor, vec3(0.0, 0.8, 0.0)),
                   dot(leftColor, vec3(0.7, 0.0, 0.7)));
    }
    
    return vec3(0.0);
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // Mapa de profundidade avançado
    float depth = advancedDepthMap(color, uv);
    
    // Ajuste de paralaxe
    float parallax = PARALLAX_STRENGTH * (depth * 2.0 - 1.0);
    
    // Imagens para cada olho
    vec2 leftUV = clamp(uv + vec2(-parallax, 0.0), 0.001, 0.999);
    vec2 rightUV = clamp(uv + vec2(parallax, 0.0), 0.001, 0.999);
    
    vec3 leftColor = HOOKED_tex(leftUV).rgb;
    vec3 rightColor = HOOKED_tex(rightUV).rgb;
    
    // Reduz ghosting
    leftColor = reduceGhosting(leftColor, rightColor);
    
    // Aplica modo anáglifo selecionado
    vec3 anaglyphColor = anaglyphByMode(leftColor, rightColor, COLOR_MODE);
    
    // Saturação ajustada para melhor visualização
    float luminance = dot(anaglyphColor, vec3(0.299, 0.587, 0.114));
    anaglyphColor = mix(vec3(luminance), anaglyphColor, 1.2);
    
    return vec4(anaglyphColor, originalColor.a);
}
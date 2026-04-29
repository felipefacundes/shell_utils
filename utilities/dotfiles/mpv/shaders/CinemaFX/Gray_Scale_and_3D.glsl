//!DESC Authentic Anaglyph 3D Effect
//!HOOK MAIN
//!BIND HOOKED

#define PARALLAX_STRENGTH 0.02
#define RED_CYAN_MODE 1
#define INTENSITY 1.0

// Função para criar deslocamento paralaxe
vec2 parallaxOffset(vec2 uv, float strength) {
    // Cria deslocamento horizontal para efeito 3D
    // Olho esquerdo (vermelho) deslocado para esquerda
    // Olho direito (ciano) deslocado para direita
    
    vec2 offset = vec2(strength, 0.0);
    
    #if RED_CYAN_MODE == 1
        // Modo vermelho/ciano padrão
        return offset;
    #else
        // Modo invertido (para testes)
        return -offset;
    #endif
}

// Separação de canais para anáglifo
vec3 anaglyphRedCyan(vec3 leftColor, vec3 rightColor) {
    // Canal vermelho do olho esquerdo
    float red = dot(leftColor, vec3(0.299, 0.587, 0.114));
    
    // Canais verde e azul do olho direito
    vec2 greenBlue = vec2(dot(rightColor, vec3(0.299, 0.587, 0.114)),
                         dot(rightColor, vec3(0.299, 0.587, 0.114)));
    
    return vec3(red, greenBlue.x, greenBlue.y);
}

// Versão melhorada com preservação de cores
vec3 anaglyphEnhanced(vec3 leftColor, vec3 rightColor) {
    // Método Dubois (mais avançado)
    mat3 leftFilter = mat3(
         0.456100, -0.0400822, -0.0152161,
        -0.0434706,  0.378476,  -0.0721527,
        -0.00605285, -0.0152161,  0.122990
    );
    
    mat3 rightFilter = mat3(
        -0.0444697,  0.0500198, -0.0176049,
         0.0200018,  0.0119478,  0.00142404,
         0.00459633, 0.00142404, 0.0960172
    );
    
    vec3 leftFiltered = leftColor * leftFilter;
    vec3 rightFiltered = rightColor * rightFilter;
    
    return leftFiltered + rightFiltered;
}

// Efeito de profundidade baseado em luminância
float depthFromLuminance(vec3 color) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Objetos mais claros parecem mais próximos
    // Objetos mais escuros parecem mais distantes
    return luminance * 2.0 - 1.0;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // Calcula profundidade baseada na luminância
    float depth = depthFromLuminance(color);
    
    // Ajusta força do paralaxe baseado na profundidade
    float adjustedParallax = PARALLAX_STRENGTH * depth;
    
    // Coordenadas para olho esquerdo (vermelho)
    vec2 leftUV = uv + parallaxOffset(uv, -adjustedParallax);
    vec3 leftColor = HOOKED_tex(clamp(leftUV, 0.0, 1.0)).rgb;
    
    // Coordenadas para olho direito (ciano)
    vec2 rightUV = uv + parallaxOffset(uv, adjustedParallax);
    vec3 rightColor = HOOKED_tex(clamp(rightUV, 0.0, 1.0)).rgb;
    
    // Aplica efeito anáglifo
    vec3 anaglyphColor;
    
    #if RED_CYAN_MODE == 1
        // Método simples vermelho/ciano
        anaglyphColor = anaglyphRedCyan(leftColor, rightColor);
    #else
        // Método Dubois (mais realista)
        anaglyphColor = anaglyphEnhanced(leftColor, rightColor);
    #endif
    
    // Interpola entre original e anáglifo
    vec3 finalColor = mix(color, anaglyphColor, INTENSITY);
    
    return vec4(finalColor, originalColor.a);
}
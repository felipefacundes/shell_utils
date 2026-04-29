//!DESC Clean Sepia Effect
//!HOOK MAIN
//!BIND HOOKED

#define SEPIA_INTENSITY 1.0

// Aplicação direta e limpa do sépia
vec3 applySepia(vec3 color) {
    // Matriz sépia balanceada
    float r = dot(color, vec3(0.393, 0.769, 0.189));
    float g = dot(color, vec3(0.349, 0.686, 0.168));
    float b = dot(color, vec3(0.272, 0.534, 0.131));
    
    return vec3(r, g, b);
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // Aplica sépia diretamente
    vec3 sepiaColor = applySepia(color);
    
    // Interpola suavemente
    color = mix(color, sepiaColor, SEPIA_INTENSITY);
    
    // Ajuste de brilho suave para efeito vintage
    color *= 0.95;
    
    return vec4(color, originalColor.a);
}
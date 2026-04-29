//!DESC Pure Grayscale Effect
//!HOOK MAIN
//!BIND HOOKED

#define GRAYSCALE_INTENSITY 1.0
#define CONTRAST 1.05

// Conversão para escala de cinza com pesos de luminância
float toGrayscale(vec3 color) {
    // Pesos padrão para percepção humana (Rec. 709)
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

// Conversão alternativa mais suave
float toGrayscaleSmooth(vec3 color) {
    // Pesos mais balanceados
    return dot(color, vec3(0.299, 0.587, 0.114));
}

// Aplica contraste
vec3 applyContrast(vec3 color, float contrast) {
    return pow(color, vec3(contrast));
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // Converte para escala de cinza
    float gray = toGrayscale(color);
    
    // Cria vetor de cor em escala de cinza
    vec3 grayscaleColor = vec3(gray);
    
    // Aplica contraste suave
    grayscaleColor = applyContrast(grayscaleColor, CONTRAST);
    
    // Interpola entre cor original e escala de cinza
    vec3 finalColor = mix(color, grayscaleColor, GRAYSCALE_INTENSITY);
    
    return vec4(finalColor, originalColor.a);
}
//!DESC Vivid and Glow Shader
//!HOOK MAIN
//!BIND HOOKED

// Parâmetros ajustáveis
#define SHARPNESS_STRENGTH 0.8
#define VIBRANCE_STRENGTH 1.2
#define GLOW_INTENSITY 0.3
#define GLOW_RADIUS 2.0

// Função para aumentar a vivacidade
vec3 applyVibrance(vec3 color, float strength) {
    float maxChannel = max(max(color.r, color.g), color.b);
    float minChannel = min(min(color.r, color.g), color.b);
    float saturation = maxChannel - minChannel;
    
    // Aumenta a saturação baseada na intensidade original
    float vibrance = (1.0 - strength) + strength * saturation;
    return mix(vec3(maxChannel), color, vibrance);
}

// Função para aplicar nitidez (unsharp mask)
vec3 applySharpness(vec3 color, vec2 pos, float strength) {
    vec2 pixelSize = 1.0 / HOOKED_size;
    
    // Amostras para o kernel de nitidez
    vec3 sample1 = HOOKED_texOff(vec2(-1.0, -1.0)).rgb;
    vec3 sample2 = HOOKED_texOff(vec2(0.0, -1.0)).rgb;
    vec3 sample3 = HOOKED_texOff(vec2(1.0, -1.0)).rgb;
    vec3 sample4 = HOOKED_texOff(vec2(-1.0, 0.0)).rgb;
    vec3 sample5 = HOOKED_texOff(vec2(1.0, 0.0)).rgb;
    vec3 sample6 = HOOKED_texOff(vec2(-1.0, 1.0)).rgb;
    vec3 sample7 = HOOKED_texOff(vec2(0.0, 1.0)).rgb;
    vec3 sample8 = HOOKED_texOff(vec2(1.0, 1.0)).rgb;
    
    // Kernel Laplaciano para detecção de bordas
    vec3 laplacian = (sample1 + sample2 + sample3 + sample4 + 
                     sample5 + sample6 + sample7 + sample8) - color * 8.0;
    
    // Aplica a nitidez
    return color - laplacian * strength * 0.1;
}

// Função para gerar glow
vec3 applyGlow(vec3 color, vec2 pos, float intensity, float radius) {
    vec3 glow = vec3(0.0);
    float totalWeight = 0.0;
    
    int samples = int(radius);
    for(int x = -samples; x <= samples; x++) {
        for(int y = -samples; y <= samples; y++) {
            if(x == 0 && y == 0) continue;
            
            vec2 offset = vec2(x, y);
            vec3 sampleColor = HOOKED_texOff(offset).rgb;
            
            // Peso gaussiano simples
            float weight = 1.0 / (1.0 + length(offset));
            glow += sampleColor * weight;
            totalWeight += weight;
        }
    }
    
    if(totalWeight > 0.0) {
        glow /= totalWeight;
    }
    
    // Mistura o glow com a cor original
    return mix(color, max(color, glow), intensity);
}

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    
    // Aplica nitidez
    vec3 sharpColor = applySharpness(originalColor.rgb, HOOKED_pos, SHARPNESS_STRENGTH);
    
    // Aplica vivacidade
    vec3 vibrantColor = applyVibrance(sharpColor, VIBRANCE_STRENGTH);
    
    // Aplica glow
    vec3 finalColor = applyGlow(vibrantColor, HOOKED_pos, GLOW_INTENSITY, GLOW_RADIUS);
    
    // Garante que as cores não ultrapassem 1.0
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, originalColor.a);
}
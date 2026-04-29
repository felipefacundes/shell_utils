//!DESC Magical Aurora Borealis Effect
//!HOOK MAIN
//!BIND HOOKED

#define AURORA_INTENSITY 0.6
#define COLOR_SATURATION 1.8
#define MOVEMENT_SPEED 0.5
#define GLOW_INTENSITY 1.2
#define PULSE_SPEED 2.0

// Função de noise para formas orgânicas
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for(int i = 0; i < 6; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

// Cores da aurora (verdes, azuis, roxos)
vec3 auroraColors(float t) {
    vec3 color1 = vec3(0.1, 0.8, 0.3);  // Verde
    vec3 color2 = vec3(0.2, 0.4, 0.8);  // Azul
    vec3 color3 = vec3(0.6, 0.2, 0.8);  // Roxo
    
    if(t < 0.33) return mix(color1, color2, t * 3.0);
    else if(t < 0.66) return mix(color2, color3, (t - 0.33) * 3.0);
    else return mix(color3, color1, (t - 0.66) * 3.0);
}

// Cria as formas ondulantes da aurora
vec3 createAurora(vec2 uv, float time) {
    uv.x += time * MOVEMENT_SPEED * 0.1;
    
    // Camadas de aurora em diferentes alturas
    float layer1 = fbm(uv * 2.0 + time * 0.3) * 0.5;
    float layer2 = fbm(uv * 3.0 - time * 0.2) * 0.3;
    float layer3 = fbm(uv * 4.0 + time * 0.4) * 0.2;
    
    // Combina as camadas
    float aurora = (layer1 + layer2 + layer3) * 2.0;
    
    // Suaviza e limita a altura
    aurora = smoothstep(0.1, 0.8, aurora) * (1.0 - uv.y);
    
    // Adiciona variação de cor
    float colorShift = fbm(uv * 1.5 + time * 0.5);
    vec3 auroraColor = auroraColors(colorShift) * COLOR_SATURATION;
    
    return auroraColor * aurora * AURORA_INTENSITY;
}

// Efeito de pulsação
float pulseEffect(float time) {
    return (sin(time * PULSE_SPEED) * 0.3 + 0.7) * 
           (sin(time * PULSE_SPEED * 1.7) * 0.2 + 0.8);
}

// Estrelas cintilantes
vec3 addStars(vec2 uv, float time) {
    vec3 stars = vec3(0.0);
    
    // Camada de estrelas
    for(int i = 0; i < 30; i++) {
        vec2 starPos = vec2(hash(vec2(float(i), 1.0)), 
                           hash(vec2(float(i), 2.0)));
        float starSize = hash(vec2(float(i), 3.0)) * 0.002;
        float brightness = hash(vec2(float(i), 4.0));
        float twinkle = sin(time * 3.0 + float(i)) * 0.5 + 0.5;
        
        float dist = distance(uv, starPos);
        if(dist < starSize) {
            stars += vec3(1.0, 0.9, 0.8) * brightness * twinkle * 0.3;
        }
    }
    
    return stars;
}

// Efeito de glow atmosférico
vec3 atmosphericGlow(vec2 uv) {
    float horizon = 1.0 - uv.y;
    vec3 glow = vec3(0.05, 0.1, 0.2) * horizon * 0.3;
    return glow;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    float time = float(frame) / 60.0;
    
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 1. Fundo atmosférico
    vec3 background = atmosphericGlow(uv);
    
    // 2. Cria a aurora boreal
    vec3 aurora = createAurora(uv, time);
    
    // 3. Adiciona estrelas
    vec3 stars = addStars(uv, time);
    
    // 4. Combina todos os elementos
    vec3 finalEffect = background + aurora + stars;
    
    // 5. Aplica pulsação
    finalEffect *= pulseEffect(time);
    
    // 6. Mistura com o conteúdo original
    color = mix(color, finalEffect, AURORA_INTENSITY);
    
    // 7. Aplica glow final
    color += finalEffect * GLOW_INTENSITY * 0.1;
    
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
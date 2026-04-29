//!DESC Bioluminescent Ocean Dreams
//!HOOK MAIN
//!BIND HOOKED

#define OCEAN_INTENSITY 0.7
#define WAVE_SPEED 0.8
#define GLOW_STRENGTH 1.5
#define PULSE_RATE 1.2
#define COLOR_CYCLING 1.0

// Funções de noise para padrões orgânicos
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
    for(int i = 0; i < 5; i++) {
        value += amplitude * noise(p);
        amplitude *= 0.5;
        p *= 2.0;
    }
    return value;
}

// Ondas do oceano
float oceanWaves(vec2 uv, float time) {
    uv.x += time * WAVE_SPEED * 0.2;
    
    float wave1 = sin(uv.x * 8.0 + time * 2.0) * 0.3;
    float wave2 = sin(uv.x * 12.0 + time * 3.0) * 0.2;
    float wave3 = sin(uv.x * 6.0 + time * 1.5) * 0.4;
    
    return (wave1 + wave2 + wave3) * 0.5;
}

// Cores bioluminescentes do oceano
vec3 oceanColors(float depth, float time) {
    // Cores de organismos bioluminescentes
    vec3 blue = vec3(0.1, 0.4, 0.8);
    vec3 cyan = vec3(0.2, 0.8, 0.9);
    vec3 purple = vec3(0.6, 0.3, 0.9);
    vec3 green = vec3(0.3, 0.9, 0.4);
    
    float cycle = sin(time * 0.5) * 0.5 + 0.5;
    
    if(depth < 0.25) return mix(blue, cyan, depth * 4.0);
    else if(depth < 0.5) return mix(cyan, purple, (depth - 0.25) * 4.0);
    else if(depth < 0.75) return mix(purple, green, (depth - 0.5) * 4.0);
    else return mix(green, blue, (depth - 0.75) * 4.0);
}

// Partículas bioluminescentes (plâncton)
vec3 bioluminescentParticles(vec2 uv, float time) {
    vec3 particles = vec3(0.0);
    
    for(int i = 0; i < 20; i++) {
        vec2 particlePos = vec2(
            hash(vec2(float(i), 1.0)) + sin(time * 0.5 + float(i)) * 0.1,
            hash(vec2(float(i), 2.0)) + cos(time * 0.3 + float(i)) * 0.05
        );
        
        float particleSize = hash(vec2(float(i), 3.0)) * 0.01;
        float brightness = hash(vec2(float(i), 4.0));
        float pulse = sin(time * 2.0 + float(i)) * 0.3 + 0.7;
        
        float dist = distance(uv, particlePos);
        if(dist < particleSize) {
            vec3 particleColor = oceanColors(hash(vec2(float(i), 5.0)), time);
            particles += particleColor * brightness * pulse * 0.4;
        }
    }
    
    return particles;
}

// Efeito de profundidade do oceano
vec3 oceanDepth(vec2 uv, float time) {
    float depth = 1.0 - uv.y; // Mais profundo na parte inferior
    
    // Camadas de água com diferentes propriedades
    float layer1 = fbm(uv * 3.0 + time * 0.5) * 0.4;
    float layer2 = fbm(uv * 6.0 - time * 0.3) * 0.3;
    float layer3 = fbm(uv * 12.0 + time * 0.7) * 0.2;
    
    float oceanPattern = (layer1 + layer2 + layer3) * depth;
    
    // Adiciona ondas na superfície
    float waves = oceanWaves(uv, time) * (1.0 - depth);
    oceanPattern += waves;
    
    return oceanColors(oceanPattern, time) * oceanPattern * OCEAN_INTENSITY;
}

// Reflexos e brilhos na água
vec3 waterHighlights(vec2 uv, float time) {
    vec2 rippleUV = uv * 4.0;
    rippleUV.x += time * 0.5;
    rippleUV.y += time * 0.3;
    
    float highlights = fbm(rippleUV) * 0.3;
    highlights = smoothstep(0.6, 0.9, highlights);
    
    return vec3(1.0, 1.0, 1.0) * highlights * 0.2;
}

// Efeito de respiração do oceano
float oceanBreathing(float time) {
    return (sin(time * PULSE_RATE) * 0.2 + 0.8) * 
           (cos(time * PULSE_RATE * 0.7) * 0.1 + 0.9);
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    float time = float(frame) / 60.0;
    
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    // 1. Camada de profundidade do oceano
    vec3 ocean = oceanDepth(uv, time);
    
    // 2. Partículas bioluminescentes
    vec3 particles = bioluminescentParticles(uv, time);
    
    // 3. Reflexos e brilhos
    vec3 highlights = waterHighlights(uv, time);
    
    // 4. Combina todos os elementos oceânicos
    vec3 oceanDream = ocean + particles + highlights;
    
    // 5. Aplica efeito de respiração
    oceanDream *= oceanBreathing(time);
    
    // 6. Aplica glow bioluminescente
    oceanDream += ocean * GLOW_STRENGTH * 0.1;
    
    // 7. Mistura com o conteúdo original
    color = mix(color, oceanDream, OCEAN_INTENSITY);
    
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
//!DESC Professional Glitch Effect (Subtle & Clean)
//!HOOK MAIN
//!BIND HOOKED

#define GLITCH_INTENSITY 0.3
#define COLOR_SHIFT 0.02
#define SCANLINE_JITTER 0.1
#define BLOCK_OFFSET 0.05
#define TIME_MULTIPLIER 2.0

// Função de noise renomeada para evitar conflito
float my_random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Função para digital noise
float digitalNoise(vec2 uv, float time) {
    vec2 id = floor(uv * 20.0);
    float n = my_random(id + time);
    return n;
}

// Efeito de color channel shift
vec3 rgbShift(vec2 uv, float intensity, float time) {
    float shift = digitalNoise(uv, time) * intensity;
    
    vec2 rOffset = vec2(shift * COLOR_SHIFT, 0.0);
    vec2 gOffset = vec2(0.0, 0.0);
    vec2 bOffset = vec2(-shift * COLOR_SHIFT * 0.5, 0.0);
    
    float r = HOOKED_tex(uv + rOffset).r;
    float g = HOOKED_tex(uv + gOffset).g;
    float b = HOOKED_tex(uv + bOffset).b;
    
    return vec3(r, g, b);
}

// Efeito de scanline jitter
vec2 scanlineJitter(vec2 uv, float intensity, float time) {
    float jitter = digitalNoise(vec2(uv.y, time), time) * intensity;
    return vec2(uv.x + jitter * SCANLINE_JITTER, uv.y);
}

// Efeito de block displacement
vec2 blockDisplacement(vec2 uv, float intensity, float time) {
    vec2 blockSize = vec2(0.1, 0.05);
    vec2 blockId = floor(uv / blockSize);
    
    float blockNoise = my_random(blockId + time);
    vec2 displacement = vec2(blockNoise - 0.5) * intensity * BLOCK_OFFSET;
    
    return uv + displacement;
}

// Efeito de digital corruption SUBSTITUÍDO - agora mais sutil
vec3 subtleCorruption(vec2 uv, float time, vec3 originalColor) {
    vec2 pixelated = floor(uv * 50.0) / 50.0;
    float corruption = digitalNoise(pixelated, time * 8.0);
    
    // Em vez de pixels brancos/pretos, usa variações sutis de brilho
    if (corruption > 0.95) {
        // Pequeno flash sutil em vez de pixel branco
        return originalColor * 1.3;
    } else if (corruption > 0.92) {
        // Pequena queda de brilho em vez de pixel preto
        return originalColor * 0.7;
    }
    
    return originalColor;
}

// Efeito de static noise
vec3 staticNoise(vec2 uv, float time, float intensity) {
    float noise = my_random(uv + time) * 2.0 - 1.0;
    return vec3(noise * intensity);
}

// Efeito de line skipping
float lineSkip(vec2 uv, float time) {
    float skip = step(0.98, digitalNoise(vec2(0.0, uv.y + time), time));
    return 1.0 - skip;
}

// Efeito de brightness flicker
float brightnessFlicker(float time) {
    float flicker = sin(time * 30.0) * 0.1 + 
                   sin(time * 17.0) * 0.05 + 
                   sin(time * 23.0) * 0.03;
    return 1.0 + flicker * 0.3;
}

// Efeito de horizontal tear
vec2 horizontalTear(vec2 uv, float time) {
    float tearPos = sin(time * 2.0) * 0.5 + 0.5;
    float tearWidth = 0.02;
    float tearOffset = 0.0;
    
    if (abs(uv.y - tearPos) < tearWidth) {
        float tearIntensity = digitalNoise(vec2(uv.y, time), time);
        tearOffset = tearIntensity * 0.1;
    }
    
    return vec2(uv.x + tearOffset, uv.y);
}

// Efeito de pixel displacement
vec2 pixelDisplacement(vec2 uv, float time) {
    vec2 displaced = uv;
    
    // Displacement baseado em noise
    float dispX = (digitalNoise(uv + time, time) - 0.5) * 0.01;
    float dispY = (digitalNoise(uv - time, time) - 0.5) * 0.005;
    
    displaced.x += dispX * GLITCH_INTENSITY;
    displaced.y += dispY * GLITCH_INTENSITY;
    
    return displaced;
}

// Nova função: color tint sutil
vec3 subtleColorTint(vec3 color, vec2 uv, float time) {
    float colorShift = digitalNoise(uv + time, time * 3.0);
    
    // Tintas de cor muito sutis e translúcidas
    if (colorShift > 0.93) {
        // Vermelho muito sutil (5% de intensidade)
        return mix(color, color * vec3(1.2, 0.9, 0.9), 0.05);
    } else if (colorShift > 0.90) {
        // Verde muito sutil (5% de intensidade)
        return mix(color, color * vec3(0.9, 1.2, 0.9), 0.05);
    } else if (colorShift > 0.87) {
        // Azul muito sutil (5% de intensidade)
        return mix(color, color * vec3(0.9, 0.9, 1.2), 0.05);
    }
    
    return color;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    float time = float(frame) / 60.0 * TIME_MULTIPLIER;
    
    // Aplica vários efeitos de glitch sequencialmente
    vec2 distortedUV = uv;
    
    // 1. Horizontal tear (ocasional)
    if (digitalNoise(vec2(0.0, time), time) > 0.7) {
        distortedUV = horizontalTear(distortedUV, time);
    }
    
    // 2. Block displacement
    distortedUV = blockDisplacement(distortedUV, GLITCH_INTENSITY, time);
    
    // 3. Scanline jitter
    distortedUV = scanlineJitter(distortedUV, GLITCH_INTENSITY, time);
    
    // 4. Pixel displacement
    distortedUV = pixelDisplacement(distortedUV, time);
    
    // Obtém a cor base com distorção
    vec4 baseColor = HOOKED_tex(distortedUV);
    vec3 color = baseColor.rgb;
    
    // 5. RGB shift
    color = rgbShift(distortedUV, GLITCH_INTENSITY, time);
    
    // 6. Static noise (reduzido)
    color += staticNoise(uv, time, GLITCH_INTENSITY * 0.05);
    
    // 7. Digital corruption SUTIL (substitui os quadrados bruscos)
    color = subtleCorruption(uv, time, color);
    
    // 8. Line skipping
    color *= lineSkip(uv, time);
    
    // 9. Brightness flicker
    color *= brightnessFlicker(time);
    
    // 10. Color tint SUTIL (substitui as tintas fortes)
    color = subtleColorTint(color, uv, time);
    
    // Garante que as cores não saiam do range
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, baseColor.a);
}
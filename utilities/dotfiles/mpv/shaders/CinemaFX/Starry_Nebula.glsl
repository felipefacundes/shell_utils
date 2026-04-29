//!DESC Cosmic Starry Nebula
//!HOOK MAIN
//!BIND HOOKED

#define NEBULA_INTENSITY 0.6
#define STAR_DENSITY 1.2
#define NEBULA_SPEED 0.3
#define TWINKLE_SPEED 2.0

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// Nebulosa colorida
vec3 nebulaClouds(vec2 uv, float time) {
    uv = uv * 2.0 - 1.0;
    
    vec2 p1 = uv * 1.5 + time * NEBULA_SPEED * 0.1;
    vec2 p2 = uv * 2.0 - time * NEBULA_SPEED * 0.2;
    vec2 p3 = uv * 3.0 + time * NEBULA_SPEED * 0.15;
    
    float n1 = noise(p1) * 0.5;
    float n2 = noise(p2) * 0.3;
    float n3 = noise(p3) * 0.2;
    
    float cloud = (n1 + n2 + n3) * 0.7;
    
    // Cores de nebulosa
    vec3 color1 = vec3(0.8, 0.3, 0.6); // Rosa
    vec3 color2 = vec3(0.3, 0.5, 0.9); // Azul
    vec3 color3 = vec3(0.9, 0.7, 0.2); // Dourado
    
    vec3 nebula = mix(color1, color2, n1);
    nebula = mix(nebula, color3, n2);
    
    return nebula * cloud * NEBULA_INTENSITY;
}

// Campo de estrelas denso
vec3 starField(vec2 uv, float time) {
    vec3 stars = vec3(0.0);
    
    for(int i = 0; i < 50; i++) {
        vec2 starUV = uv * 10.0;
        vec2 starPos = vec2(hash(vec2(float(i))), hash(vec2(float(i) + 1.0)));
        
        float star = 1.0 - smoothstep(0.0, 0.01, distance(starUV, starPos));
        
        float brightness = hash(vec2(float(i) + 2.0));
        float twinkle = sin(time * TWINKLE_SPEED + float(i)) * 0.3 + 0.7;
        
        vec3 starColor = mix(vec3(1.0, 1.0, 1.0), 
                            vec3(0.8, 0.9, 1.0), 
                            hash(vec2(float(i) + 3.0)));
        
        stars += starColor * star * brightness * twinkle * 0.4;
    }
    
    return stars * STAR_DENSITY;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;
    float time = float(frame) / 60.0;
    
    vec4 originalColor = HOOKED_tex(uv);
    vec3 color = originalColor.rgb;
    
    vec3 nebula = nebulaClouds(uv, time);
    vec3 stars = starField(uv, time);
    
    color = mix(color, nebula + stars, NEBULA_INTENSITY);
    color = clamp(color, 0.0, 1.0);
    
    return vec4(color, originalColor.a);
}
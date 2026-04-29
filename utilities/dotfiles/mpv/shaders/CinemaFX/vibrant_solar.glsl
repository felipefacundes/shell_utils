//!DESC Vivid Colors and Glow - Sharpen Pass
//!HOOK MAIN
//!BIND HOOKED
//!SAVE SHARPENED
//!COMPONENTS 4

// Parâmetros de nitidez
#define SHARPNESS 0.5

vec4 hook() {
    vec2 pt = HOOKED_pt;
    vec4 orig = HOOKED_tex(HOOKED_pos);
    
    // Kernel gaussiano 3x3 para desfoque
    vec4 blurred = vec4(0.0);
    blurred += HOOKED_texOff(vec2(-1.0, -1.0)) * 1.0;
    blurred += HOOKED_texOff(vec2( 0.0, -1.0)) * 2.0;
    blurred += HOOKED_texOff(vec2( 1.0, -1.0)) * 1.0;
    blurred += HOOKED_texOff(vec2(-1.0,  0.0)) * 2.0;
    blurred += HOOKED_texOff(vec2( 0.0,  0.0)) * 4.0;
    blurred += HOOKED_texOff(vec2( 1.0,  0.0)) * 2.0;
    blurred += HOOKED_texOff(vec2(-1.0,  1.0)) * 1.0;
    blurred += HOOKED_texOff(vec2( 0.0,  1.0)) * 2.0;
    blurred += HOOKED_texOff(vec2( 1.0,  1.0)) * 1.0;
    blurred /= 16.0;
    
    // Unsharp mask
    vec4 sharpened = orig + (orig - blurred) * SHARPNESS;
    
    return sharpened;
}

//!DESC Vivid Colors and Glow - Glow Pass
//!HOOK MAIN
//!BIND HOOKED
//!BIND SHARPENED
//!SAVE GLOWED
//!COMPONENTS 4

// Parâmetros de glow
#define GLOW_STRENGTH 0.3
#define GLOW_RADIUS 2.0

vec4 hook() {
    vec4 sharpened = SHARPENED_tex(HOOKED_pos);
    
    // Amostragem do glow em padrão circular
    vec4 glow = vec4(0.0);
    float samples = 0.0;
    
    // 8 direções, 2 níveis de distância
    float angles[8];
    angles[0] = 0.0;        // Direita
    angles[1] = 0.785398;   // Diagonal superior direita
    angles[2] = 1.570796;   // Cima
    angles[3] = 2.356194;   // Diagonal superior esquerda
    angles[4] = 3.141593;   // Esquerda
    angles[5] = 3.926991;   // Diagonal inferior esquerda
    angles[6] = 4.712389;   // Baixo
    angles[7] = 5.497787;   // Diagonal inferior direita
    
    for (int i = 0; i < 8; i++) {
        float angle = angles[i];
        for (float dist = 1.0; dist <= GLOW_RADIUS; dist += 1.0) {
            vec2 offset = vec2(cos(angle), sin(angle)) * dist;
            glow += SHARPENED_texOff(offset);
            samples += 1.0;
        }
    }
    glow /= samples;
    
    // Combina nitidez com glow
    vec4 result = sharpened + glow * GLOW_STRENGTH;
    
    return result;
}

//!DESC Vivid Colors and Glow - Saturation and Final
//!HOOK MAIN
//!BIND HOOKED
//!BIND GLOWED

// Parâmetros de saturação
#define SATURATION 1.4

// Converte RGB para HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Converte HSV para RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 hook() {
    vec4 color = GLOWED_tex(HOOKED_pos);
    
    // Aumenta a saturação
    vec3 hsv = rgb2hsv(color.rgb);
    hsv.y = clamp(hsv.y * SATURATION, 0.0, 1.0);
    vec3 vibrant = hsv2rgb(hsv);
    
    // Boost adicional em áreas brilhantes
    float luminance = dot(vibrant, vec3(0.299, 0.587, 0.114));
    vibrant = mix(vibrant, vibrant * 1.1, luminance * 0.3);
    
    return vec4(vibrant, color.a);
}
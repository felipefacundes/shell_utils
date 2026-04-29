//!DESC Adjustable Grayscale
//!HOOK MAIN
//!BIND HOOKED

#define INTENSITY 1.0

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // Calcula escala de cinza
    float gray = dot(color, vec3(0.2126, 0.7152, 0.0722));
    
    // Interpola entre cor original e escala de cinza
    vec3 result = mix(color, vec3(gray), INTENSITY);
    
    return vec4(result, originalColor.a);
}
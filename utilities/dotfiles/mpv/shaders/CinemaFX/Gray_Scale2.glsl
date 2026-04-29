//!DESC Clean Grayscale
//!HOOK MAIN
//!BIND HOOKED

vec4 hook() {
    vec4 originalColor = HOOKED_tex(HOOKED_pos);
    vec3 color = originalColor.rgb;
    
    // Conversão direta para escala de cinza
    float gray = dot(color, vec3(0.2126, 0.7152, 0.0722));
    
    return vec4(vec3(gray), originalColor.a);
}
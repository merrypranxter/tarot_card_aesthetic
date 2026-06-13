// Tarot Card Aesthetic — Fragment Shader Stub
// Border SDF, gold shimmer, star field, pip geometry, sky gradient

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_border_weight;
uniform float u_gold_intensity;
uniform float u_outline_weight;
uniform vec3 u_sky_color;
uniform vec3 u_ground_color;
uniform float u_symbol_density;
uniform int u_arcana_number;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5); }

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    
    // Card aspect ratio (1:1.73)
    float card_w = 0.6;
    float card_h = card_w * 1.73;
    vec2 card_uv = (uv - 0.5) / vec2(card_w, card_h) + 0.5;
    
    float card = smoothstep(0.01, 0.0, abs(card_uv.x - 0.5) - 0.5) * 
                 smoothstep(0.01, 0.0, abs(card_uv.y - 0.5) - 0.5);
    
    // Border
    float border = smoothstep(0.0, u_border_weight, abs(card_uv.x - 0.5) - 0.45) *
                   smoothstep(0.0, u_border_weight, abs(card_uv.y - 0.5) - 0.45);
    
    // Gold shimmer on border
    float gold = sin(card_uv.x * 20.0 + u_time) * sin(card_uv.y * 20.0 + u_time);
    gold = smoothstep(0.0, 1.0, gold * 0.5 + 0.5) * u_gold_intensity;
    
    // Sky/ground inside card
    vec3 sky = mix(u_ground_color, u_sky_color, card_uv.y);
    
    // Stars
    float star = step(0.98, hash(floor(card_uv * 50.0))) * smoothstep(0.0, 0.02, card_uv.y - 0.6);
    sky += vec3(1.0, 0.84, 0.0) * star * u_gold_intensity;
    
    // Symbol scatter
    float sym = step(0.95, hash(floor(card_uv * 30.0))) * card;
    vec3 symbol_col = vec3(0.8, 0.0, 0.0) * sym * u_symbol_density;
    
    vec3 col = mix(vec3(0.1), sky, card);
    col = mix(col, vec3(0.8, 0.65, 0.2), border * (0.5 + gold));
    col += symbol_col;
    
    gl_FragColor = vec4(col, 1.0);
}

// Indie Minimal — Contemporary Single-Line Style
// Aesthetic: INDIE_MINIMAL
// Palette: White #FAFAFA, Near-Black #1A1A1A, Sage accent (via u_sky_color)
//
// Sky grammar: no literal sky — the white ground IS the sky, the page, the space.
//   The accent colour (u_sky_color) bleeds in as subtle washes: sage = growth/plant,
//   dusty rose = the feminine, slate = meditative cool, coral = vitality.
//
// Indie minimal vocabulary:
//   Hairline strokes (1px equivalent) — precision over drama
//   Single botanical: moon/crescent + fern fronds, or moth wings, or single flower
//   One circle (the moon, the cycle, the whole)
//   Negative space used intentionally: emptiness is content
//   Title: lowercase, thin sans-serif style (represented as hairline rectangle band)
//   No number bar border — number is part of the image, tastefully small
//
// Structure: hairline single-line border → wide white margin →
//            sparse botanical illustration (hairline) → thin title serif →
//            small number (top-left or top-centre, plain)

precision highp float;
uniform float u_time;
uniform vec2  u_resolution;
uniform float u_border_weight;
uniform float u_gold_intensity;
uniform float u_outline_weight;
uniform vec3  u_sky_color;
uniform vec3  u_ground_color;
uniform float u_symbol_density;
uniform int   u_arcana_number;

float hash(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float hash1(float v){ return fract(sin(v*127.1)*43758.5453); }
float sdCircle(vec2 p, float r){ return length(p) - r; }
float sdBox(vec2 p, vec2 b){ vec2 d=abs(p)-b; return length(max(d,0.0))+min(max(d.x,d.y),0.0); }
float sdLine(vec2 p, vec2 a, vec2 b){
    vec2 pa=p-a, ba=b-a;
    float h=clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0);
    return length(pa-ba*h);
}

// Hairline: stroke of given width
float hairline(float d, float w){ return smoothstep(w, w*0.3, abs(d)); }

// Crescent moon: large circle minus offset small circle
float crescent(vec2 p, float r, float offset){
    float outer = sdCircle(p, r);
    float inner = sdCircle(p + vec2(offset, 0.0), r * 0.85);
    // crescent = inside outer, outside inner
    float mask = step(0.0, -outer) * step(0.0, inner);
    return hairline(outer, 0.003) * (1.0 - step(0.0, -inner)) + mask * 0.8;
}

// Fern frond: recursive-style branching (approximated as series of arcs)
float fernFrond(vec2 p, vec2 base, float len, float angle, int depth){
    float d = 1e9;
    vec2 dir = vec2(cos(angle), sin(angle));
    vec2 tip = base + dir * len;
    d = min(d, sdLine(p, base, tip));
    if(depth > 0){
        // Sub-fronds along the stem
        float seg = len / 5.0;
        for(int i = 1; i <= 5; i++){
            vec2 pt = base + dir * (float(i) * seg);
            float sub_len = len * 0.3 * (1.0 - float(i) * 0.15);
            // Right branch
            float a_r = angle + 0.55;
            vec2 dir_r = vec2(cos(a_r), sin(a_r));
            d = min(d, sdLine(p, pt, pt + dir_r * sub_len));
            // Left branch
            float a_l = angle - 0.55;
            vec2 dir_l = vec2(cos(a_l), sin(a_l));
            d = min(d, sdLine(p, pt, pt + dir_l * sub_len));
        }
    }
    return smoothstep(0.004, 0.001, d);
}

// Single delicate botanical circle (moon)
float moonCircle(vec2 p, float r){
    return hairline(sdCircle(p, r), 0.003);
}

// Minimal dot — small filled circle
float dot_(vec2 p, float r){ return smoothstep(r, r*0.5, length(p)); }

void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float sar = u_resolution.x / u_resolution.y;

    float ch = 0.88;
    float cw = ch / (1.73 * sar);
    vec2 cuv = (uv - 0.5 + vec2(cw, ch) * 0.5) / vec2(cw, ch);
    float mask = step(0.0, cuv.x) * step(cuv.x, 1.0) * step(0.0, cuv.y) * step(cuv.y, 1.0);

    // Wide margin for indie style — the border IS the breathing room
    float bw    = u_border_weight * 0.03 + 0.04;
    float edge  = min(min(cuv.x, 1.0-cuv.x), min(cuv.y, 1.0-cuv.y));
    float in_outer  = step(edge, bw);
    // No thick border — just hairline. So in_outer is only 1px equivalent.
    float in_inner  = 1.0 - in_outer;

    float title_bar   = step(cuv.y, 0.10) * in_inner;
    float number_bar  = step(0.92, cuv.y)  * in_inner;
    float image_field = in_inner * (1.0 - title_bar) * (1.0 - number_bar);

    // ── Palette ───────────────────────────────────────────────────────────────
    vec3 WHITE   = u_ground_color;  // near-white
    vec3 INK     = vec3(0.10, 0.10, 0.10);
    vec3 ACCENT  = u_sky_color;     // sage green / dusty pink / etc.
    // Desaturate accent slightly for tasteful use
    float lum = dot(ACCENT, vec3(0.2126, 0.7152, 0.0722));
    vec3 ACC_SOFT = mix(ACCENT, vec3(lum), 0.35);

    // ── Card base: white / very pale ─────────────────────────────────────────
    vec3 col = vec3(0.15);
    col = mix(col, WHITE, mask);

    // Subtle paper texture
    float tex = hash(floor(cuv * 180.0));
    col = mix(col, WHITE * (0.985 + tex * 0.015), mask);

    // ── Accent colour wash (very subtle) ─────────────────────────────────────
    {
        float wash = 1.0 - length((cuv - vec2(0.5, 0.55)) * vec2(0.6, 0.9));
        wash = clamp(wash * wash * 0.18, 0.0, 1.0);
        col = mix(col, ACC_SOFT, mask * image_field * wash * (1.0 - u_gold_intensity));
    }

    // ── Botanical illustration: crescent moon + fern fronds ──────────────────
    float INK_alpha = u_outline_weight;

    // Moon (upper centre of image field)
    {
        vec2 moon_c = vec2(0.5, 0.70);
        float r = 0.075;
        // Full circle outline
        float circ = moonCircle(cuv - moon_c, r);
        col = mix(col, INK, mask * image_field * circ * INK_alpha);

        // Crescent cut: inner circle offset
        float inner_d = sdCircle(cuv - moon_c + vec2(r * 0.45, 0.0), r * 0.82);
        float outer_d = sdCircle(cuv - moon_c, r);
        float cresc_fill = step(0.0, -outer_d) * step(0.0, inner_d);
        col = mix(col, INK * 0.9, mask * image_field * cresc_fill * INK_alpha * 0.7);
    }

    // Central fern frond (main vertical stem)
    {
        vec2 fern_base = vec2(0.5, 0.17);
        float fl = fernFrond(cuv, fern_base, 0.38, 1.5708, 1);
        col = mix(col, INK, mask * image_field * fl * INK_alpha);
    }

    // Secondary fern frond (leaning left)
    {
        vec2 fb2 = vec2(0.42, 0.20);
        float fl2 = fernFrond(cuv, fb2, 0.25, 1.9, 1);
        col = mix(col, INK, mask * image_field * fl2 * INK_alpha * 0.75);
    }

    // Secondary fern frond (leaning right)
    {
        vec2 fb3 = vec2(0.58, 0.20);
        float fl3 = fernFrond(cuv, fb3, 0.25, 1.22, 1);
        col = mix(col, INK, mask * image_field * fl3 * INK_alpha * 0.75);
    }

    // Small accent dots (dewdrops / seeds)
    {
        float cnt = u_symbol_density * 7.0;
        for(int si = 0; si < 7; si++){
            if(float(si) >= cnt) break;
            float fsi = float(si);
            float h = hash1(fsi * 8.1);
            float h2 = hash1(fsi * 14.7 + 1.1);
            vec2 sp = vec2(0.25 + h * 0.50, 0.22 + h2 * 0.44);
            float d = dot_(cuv - sp, 0.007);
            col = mix(col, ACCENT, mask * image_field * d * 0.85);
        }
    }

    // Single accent circle ring (symbolises the whole / the cycle)
    {
        float ring = hairline(sdCircle(cuv - vec2(0.5, 0.47), 0.16), 0.0025);
        col = mix(col, ACC_SOFT * 0.9, mask * image_field * ring * 0.6);
    }

    // ── Border: single hairline ───────────────────────────────────────────────
    {
        float bl = step(edge, bw) - step(edge, bw - 0.0035);
        col = mix(col, INK * 0.85, mask * bl * INK_alpha * 0.9);
    }

    // ── Title bar: minimal — just a thin line above it, text implied ──────────
    {
        // Thin separator line at top of title bar
        float sep = hairline(cuv.y - 0.10, 0.0025);
        col = mix(col, INK * 0.6, mask * in_inner * sep * INK_alpha * 0.7);

        // Title text block (hairline, sparse)
        float ttext = smoothstep(0.003, 0.0, abs(cuv.y - 0.054) - 0.014)
                    * smoothstep(0.005, 0.0, abs(cuv.x - 0.5)   - 0.22);
        col = mix(col, INK * 0.85, mask * title_bar * ttext * INK_alpha * 0.7);
    }

    // ── Number: small, top left, understated ─────────────────────────────────
    {
        float ntext = smoothstep(0.003, 0.0, abs(cuv.y - 0.952) - 0.013)
                    * smoothstep(0.005, 0.0, abs(cuv.x - 0.5)   - 0.045);
        col = mix(col, INK * 0.7, mask * number_bar * ntext * INK_alpha * 0.6);
    }

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}

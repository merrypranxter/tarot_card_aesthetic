// Rider-Waite Revival — Classic 1909 Illustrated Style
// Aesthetic: RIDER_WAITE_REVIVAL
// Palette: Cream #FFF8E7, Gold #FFD700, Deep Red #8B0000, Midnight Blue #191970, Green #228B22
//
// Sky grammar:
//   Yellow sky  → day consciousness, solar will, clarity. The Fool walks toward it.
//   Blue sky    → water, emotion, the unconscious. Used for Cups court cards.
//   Grey sky    → storm, challenge, transformation. The Tower, Five of Swords.
//
// Structure: double-line gold border → inner cream margin → image field →
//            title bar (bottom 12%) → number bar (top 9%)

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

// ── Utilities ────────────────────────────────────────────────────────────────
float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float hash1(float v){ return fract(sin(v * 127.1) * 43758.5453); }
float smoothHash(vec2 p){
    vec2 i = floor(p); vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i+vec2(1,0)), f.x),
               mix(hash(i+vec2(0,1)), hash(i+vec2(1,1)), f.x), f.y);
}
float sdBox(vec2 p, vec2 b){ vec2 d = abs(p) - b; return length(max(d,0.0)) + min(max(d.x,d.y),0.0); }
float sdCircle(vec2 p, float r){ return length(p) - r; }
float sdDiamond(vec2 p, float s){ return (abs(p.x) + abs(p.y)) / s - 1.0; }

// 8-point cross star flare (Rider-Waite stars)
float star8(vec2 p, float r){
    vec2 q = abs(p);
    float d = min(max(q.x, q.y), (q.x + q.y) * 0.707);
    return smoothstep(r, r * 0.5, d);
}

// Ornate corner diamond ornament
float cornerDeco(vec2 p, float sz){
    float d = min(abs(sdDiamond(p, sz)), abs(sdDiamond(p, sz * 0.55)));
    return smoothstep(0.005, 0.001, d);
}

// Rose / wheel spoke motif (simplified)
float roseMotif(vec2 p, float r){
    float d = sdCircle(p, r);
    float ring = smoothstep(0.004, 0.001, abs(d));
    float spokes = 0.0;
    for(int i = 0; i < 8; i++){
        float a = float(i) * 0.7854;
        vec2 dir = vec2(cos(a), sin(a));
        float along = dot(p, dir);
        float perp  = abs(dot(p, vec2(-dir.y, dir.x)));
        spokes += smoothstep(0.003, 0.0, perp) * step(0.0, along) * step(along, r);
    }
    return max(ring, min(spokes, 1.0));
}

// ── Card Layout ──────────────────────────────────────────────────────────────
void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float sar = u_resolution.x / u_resolution.y;

    float ch = 0.88;
    float cw = ch / (1.73 * sar);
    vec2 cuv = (uv - 0.5 + vec2(cw, ch) * 0.5) / vec2(cw, ch);
    float mask = step(0.0, cuv.x) * step(cuv.x, 1.0) * step(0.0, cuv.y) * step(cuv.y, 1.0);

    float bw = u_border_weight * 0.04 + 0.022;
    float edge = min(min(cuv.x, 1.0 - cuv.x), min(cuv.y, 1.0 - cuv.y));

    float in_outer  = step(edge, bw);
    float in_margin = step(edge, bw * 1.9) * (1.0 - in_outer);
    float in_inner  = (1.0 - in_outer) * (1.0 - in_margin);

    float title_bar   = step(cuv.y, 0.115) * in_inner;
    float number_bar  = step(0.905, cuv.y)  * in_inner;
    float image_field = in_inner * (1.0 - title_bar) * (1.0 - number_bar);

    // ── Palette ───────────────────────────────────────────────────────────────
    vec3 CREAM = u_ground_color;
    vec3 GOLD  = mix(vec3(0.75, 0.60, 0.15), vec3(1.0, 0.85, 0.0), u_gold_intensity);
    vec3 DRED  = vec3(0.545, 0.0, 0.0);
    vec3 MBLUE = vec3(0.098, 0.098, 0.44);
    vec3 GREEN = vec3(0.133, 0.545, 0.133);
    vec3 SKY   = u_sky_color;

    // ── Image field: sky + earth ──────────────────────────────────────────────
    float ify = (cuv.y - 0.115) / 0.79;  // 0..1 in image field

    vec3 sky_col  = mix(CREAM * 0.88, SKY, smoothstep(0.38, 0.68, ify));
    vec3 grnd_col = mix(GREEN * 0.65 + CREAM * 0.35, sky_col, smoothstep(0.0, 0.32, ify));
    vec3 img = grnd_col;

    // Mountain silhouette
    float hill1 = smoothHash(vec2(cuv.x * 3.2, 0.0)) * 0.10 + 0.22;
    float hill2 = smoothHash(vec2(cuv.x * 5.1 + 2.3, 0.0)) * 0.07 + 0.28;
    float hills  = max(smoothstep(0.004, -0.004, ify - hill1),
                       smoothstep(0.004, -0.004, ify - hill2));
    img = mix(img, MBLUE * 0.55 + CREAM * 0.2, hills * 0.75);

    // ── Sun disk with rays ────────────────────────────────────────────────────
    {
        vec2 sun_c = vec2(0.5, 0.76);
        float sun_r = 0.058;
        float sun_d = sdCircle(cuv - sun_c, sun_r);
        img = mix(img, SKY * 1.05, smoothstep(0.10, 0.0, abs(sun_d + 0.05)) * 0.35);
        img = mix(img, GOLD, smoothstep(0.004, -0.002, sun_d) * u_gold_intensity);
        // 8 rays
        for(int ri = 0; ri < 8; ri++){
            float a = float(ri) * 0.7854;
            vec2 dir = vec2(cos(a), sin(a));
            vec2 pp   = cuv - sun_c;
            float along = dot(pp, dir);
            float perp  = abs(dot(pp, vec2(-dir.y, dir.x)));
            float ray = smoothstep(0.006, 0.0, perp) * step(sun_r + 0.004, along) * step(along, sun_r + 0.05);
            img = mix(img, GOLD, ray * u_gold_intensity);
        }
    }

    // ── 8-point stars in sky ──────────────────────────────────────────────────
    {
        vec2 star_grid = cuv * vec2(7.0, 9.0);
        vec2 sc = floor(star_grid);
        vec2 sf = fract(star_grid);
        float h = hash(sc);
        if(h > 1.0 - u_symbol_density * 0.35 && ify > 0.42){
            float s = star8(sf - 0.5, 0.22);
            float flicker = 0.75 + 0.25 * sin(u_time * 1.8 + h * 6.28);
            img += GOLD * s * flicker * u_gold_intensity * smoothstep(0.42, 0.58, ify);
        }
    }

    // ── Crowned robed figure ──────────────────────────────────────────────────
    {
        // Head
        vec2 hc = vec2(0.5, 0.57);
        float head = smoothstep(0.004, -0.002, sdCircle(cuv - hc, 0.042));
        img = mix(img, CREAM, head);

        // Crown (5 points)
        for(int ci = 0; ci < 5; ci++){
            float cx = (float(ci) - 2.0) * 0.019;
            float cy = float(ci % 2) * 0.016 + 0.043;
            float cp = smoothstep(0.004, -0.001, sdCircle(cuv - hc - vec2(cx, cy), 0.011));
            img = mix(img, GOLD, cp * u_gold_intensity);
        }

        // Body (red robe)
        vec2 bc = vec2(0.5, 0.40);
        float body = smoothstep(0.004, -0.002, sdBox(cuv - bc, vec2(0.06, 0.085)));
        img = mix(img, DRED * 0.85, body);

        // Robe outline
        float outline_mask = body * smoothstep(0.062, 0.055, sdBox(cuv - bc, vec2(0.06, 0.085)) + 0.003);
        img = mix(img, vec3(0.04), outline_mask * u_outline_weight * 12.0);

        // Head outline
        float hout = head * smoothstep(0.043, 0.037, sdCircle(cuv - hc, 0.042) + 0.003);
        img = mix(img, vec3(0.04), hout * u_outline_weight * 10.0);

        // Staff / wand
        vec2 wc = vec2(0.62, 0.42);
        float staff = smoothstep(0.003, -0.001, sdBox(cuv - wc, vec2(0.007, 0.09)));
        img = mix(img, CREAM * 0.8, staff);
        img = mix(img, vec3(0.04), staff * smoothstep(0.008, 0.005, sdBox(cuv - wc, vec2(0.007, 0.09)) + 0.002) * u_outline_weight * 8.0);
    }

    // ── Symbol scatter (pentacle wheels) ─────────────────────────────────────
    {
        float cnt = floor(u_symbol_density * 10.0 + 1.0);
        for(int si = 0; si < 10; si++){
            if(float(si) >= cnt) break;
            float fsi = float(si);
            float h = hash1(fsi * 9.3);
            float h2 = hash1(fsi * 17.1 + 3.0);
            vec2 sp = vec2(0.12 + h * 0.76, 0.14 + h2 * 0.68);
            float dist = length(cuv - sp);
            if(dist < 0.06){
                float motif = roseMotif(cuv - sp, 0.022);
                img = mix(img, GOLD, motif * u_gold_intensity * 0.55);
            }
        }
    }

    // ── Border ────────────────────────────────────────────────────────────────
    // Outer gold border with shimmer
    float shimmer = sin(cuv.x * 38.0 + u_time * 0.5) * sin(cuv.y * 38.0 + u_time * 0.5) * 0.5 + 0.5;
    vec3 border_col = mix(GOLD * 0.65, GOLD, shimmer * u_gold_intensity);

    // Inner decorative line
    float inner_line = smoothstep(0.0028, 0.0, abs(edge - bw * 1.9)) * mask;

    // Corner diamonds
    float cdeco = 0.0;
    vec2 corn[4];
    corn[0] = vec2(bw * 0.85, bw * 0.85);
    corn[1] = vec2(1.0 - bw * 0.85, bw * 0.85);
    corn[2] = vec2(bw * 0.85, 1.0 - bw * 0.85);
    corn[3] = vec2(1.0 - bw * 0.85, 1.0 - bw * 0.85);
    for(int ci = 0; ci < 4; ci++){
        cdeco = max(cdeco, cornerDeco(cuv - corn[ci], bw * 0.88));
    }

    // ── Title bar ─────────────────────────────────────────────────────────────
    vec3 title_dark = MBLUE * 0.45 + DRED * 0.25;
    // Centered text block placeholder
    float ttext = smoothstep(0.0025, 0.0, abs(cuv.y - 0.057) - 0.022)
                * smoothstep(0.004, 0.0, abs(cuv.x - 0.5) - 0.28);

    // ── Number bar ─────────────────────────────────────────────────────────────
    float ntext = smoothstep(0.0025, 0.0, abs(cuv.y - 0.952) - 0.018)
                * smoothstep(0.004, 0.0, abs(cuv.x - 0.5) - 0.07);

    // ── Compose ───────────────────────────────────────────────────────────────
    vec3 col = vec3(0.07);                              // outer background
    col = mix(col, CREAM, mask);                        // card ground
    col = mix(col, img, mask * image_field);            // image field
    col = mix(col, title_dark, mask * title_bar * 0.88);
    col = mix(col, GOLD, mask * title_bar * ttext * u_gold_intensity);
    col = mix(col, title_dark * 0.75, mask * number_bar * 0.55);
    col = mix(col, GOLD, mask * number_bar * ntext * u_gold_intensity);
    col = mix(col, CREAM * 0.95, mask * in_margin);
    col = mix(col, border_col, mask * in_outer);
    col = mix(col, GOLD * 0.9, inner_line * u_gold_intensity);
    col = mix(col, GOLD, mask * cdeco * u_gold_intensity);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}

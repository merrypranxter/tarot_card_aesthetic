// Thoth Aethyr — Crowley/Harris Esoteric Abstraction
// Aesthetic: THOTH_AETHYR
// Palette: Near-black #1C1C1C, Gold #DAA520, Dark Magenta #8B008B, Dark Blue #00008B
//
// Sky grammar: the Thoth deck has no sky — it has AETHER. The ground is the void.
//   Colour here is emanation: gold = Kether (crown), blue = Chokmah (wisdom),
//   magenta = Binah (understanding), the structure below is the Tree of Life itself.
//
// Symbolic vocabulary:
//   The Hexagram (Star of David)   — union of above and below, fire+water
//   The Pentagon / Pentagram       — five elements, the human figure inscribed
//   Planetary circles with glyphs  — astrological attribution of each card
//   Serpent / spiral               — Kundalini, the path of the lightning flash
//   Triangle pointing up/down      — fire (△) and water (▽) Platonic solids
//
// Structure: thin ornate gold line border → void field →
//            geometric diagram (astrological/kabbalistic) → title serif-italic →
//            number (Roman, top centre, gold)

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

// Equilateral triangle SDF
float sdTriangle(vec2 p, float r){
    const float k = 1.7320508;
    p.x = abs(p.x) - r;
    p.y = p.y + r / k;
    if(p.x + k * p.y > 0.0) p = vec2(p.x - k*p.y, -k*p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0*r, 0.0);
    return -length(p) * sign(p.y);
}

// Hexagram (Star of David): two overlapping triangles
float hexagram(vec2 p, float r){
    float tri1 = abs(sdTriangle(p, r));
    float tri2 = abs(sdTriangle(vec2(p.x, -p.y), r));
    return smoothstep(0.004, 0.001, min(tri1, tri2));
}

// Pentagram line drawing (5-pointed star outline)
float pentagram(vec2 p, float r){
    float d = 1e9;
    const float TAU = 6.28318;
    for(int i = 0; i < 5; i++){
        float a0 = TAU * float(i)     / 5.0 - 1.5708;
        float a1 = TAU * float(i + 2) / 5.0 - 1.5708;
        vec2 pa = vec2(cos(a0), sin(a0)) * r;
        vec2 pb = vec2(cos(a1), sin(a1)) * r;
        vec2 pp = p - pa;
        vec2 ba = pb - pa;
        float h = clamp(dot(pp,ba)/dot(ba,ba), 0.0, 1.0);
        d = min(d, length(pp - ba*h));
    }
    return smoothstep(0.005, 0.001, d);
}

// Ring with tick marks (planetary glyph ring)
float glyphRing(vec2 p, float r, int ticks){
    float ring = smoothstep(0.0035, 0.001, abs(sdCircle(p, r)));
    float marks = 0.0;
    for(int i = 0; i < 12; i++){
        if(i >= ticks) break;
        float a = float(i) * 6.28318 / float(ticks);
        vec2 dir = vec2(cos(a), sin(a));
        vec2 tp = p - dir * r;
        float tick = smoothstep(0.003, 0.0, sdBox(tp, vec2(0.003, 0.012)));
        marks = max(marks, tick);
    }
    return max(ring, marks);
}

// Lightning flash / serpent path connecting sephiroth
float lightningPath(vec2 p){
    // Simplified 3-segment zigzag
    float d = 1e9;
    vec2 pts[4];
    pts[0] = vec2( 0.05,  0.35);
    pts[1] = vec2(-0.08,  0.10);
    pts[2] = vec2( 0.06, -0.10);
    pts[3] = vec2(-0.05, -0.32);
    for(int i = 0; i < 3; i++){
        vec2 pa = pts[i]; vec2 pb = pts[i+1];
        vec2 pp = p - pa; vec2 ba = pb - pa;
        float h = clamp(dot(pp,ba)/dot(ba,ba), 0.0, 1.0);
        d = min(d, length(pp - ba*h));
    }
    return smoothstep(0.005, 0.001, d);
}

// Kabbalistic Tree of Life (10 sephiroth as circles connected by paths)
float treeOfLife(vec2 p, float scale){
    // 10 sephiroth positions (traditional layout)
    vec2 seph[10];
    seph[0] = vec2( 0.0,  0.45) * scale;   // Kether
    seph[1] = vec2( 0.20,  0.28) * scale;  // Chokmah
    seph[2] = vec2(-0.20,  0.28) * scale;  // Binah
    seph[3] = vec2( 0.20,  0.05) * scale;  // Chesed
    seph[4] = vec2(-0.20,  0.05) * scale;  // Geburah
    seph[5] = vec2( 0.0,  -0.08) * scale;  // Tiphareth
    seph[6] = vec2( 0.20, -0.22) * scale;  // Netzach
    seph[7] = vec2(-0.20, -0.22) * scale;  // Hod
    seph[8] = vec2( 0.0,  -0.36) * scale;  // Yesod
    seph[9] = vec2( 0.0,  -0.50) * scale;  // Malkuth

    float r_seph = 0.025 * scale;
    float d_circles = 1e9;
    for(int i = 0; i < 10; i++){
        d_circles = min(d_circles, abs(sdCircle(p - seph[i], r_seph)));
    }
    float circles = smoothstep(0.004, 0.001, d_circles);

    // 22 paths (simplified: 15 key connections)
    int pa_idx[15]; int pb_idx[15];
    pa_idx[0]=0; pb_idx[0]=1;   pa_idx[1]=0; pb_idx[1]=2;
    pa_idx[2]=0; pb_idx[2]=5;   pa_idx[3]=1; pb_idx[3]=2;
    pa_idx[4]=1; pb_idx[4]=3;   pa_idx[5]=2; pb_idx[5]=4;
    pa_idx[6]=3; pb_idx[6]=4;   pa_idx[7]=3; pb_idx[7]=5;
    pa_idx[8]=4; pb_idx[8]=5;   pa_idx[9]=5; pb_idx[9]=6;
    pa_idx[10]=5; pb_idx[10]=7; pa_idx[11]=6; pb_idx[11]=7;
    pa_idx[12]=6; pb_idx[12]=8; pa_idx[13]=7; pb_idx[13]=8;
    pa_idx[14]=8; pb_idx[14]=9;

    float d_paths = 1e9;
    for(int i = 0; i < 15; i++){
        vec2 a = seph[pa_idx[i]]; vec2 b = seph[pb_idx[i]];
        vec2 pp = p - a; vec2 ba = b - a;
        float h = clamp(dot(pp,ba)/dot(ba,ba), 0.0, 1.0);
        d_paths = min(d_paths, length(pp - ba*h));
    }
    float paths = smoothstep(0.003, 0.001, d_paths);

    return max(circles, paths);
}

void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float sar = u_resolution.x / u_resolution.y;

    float ch = 0.88;
    float cw = ch / (1.73 * sar);
    vec2 cuv = (uv - 0.5 + vec2(cw, ch) * 0.5) / vec2(cw, ch);
    float mask = step(0.0, cuv.x) * step(cuv.x, 1.0) * step(0.0, cuv.y) * step(cuv.y, 1.0);

    float bw    = u_border_weight * 0.04 + 0.018;
    float edge  = min(min(cuv.x, 1.0-cuv.x), min(cuv.y, 1.0-cuv.y));
    float in_outer  = step(edge, bw);
    float in_margin = step(edge, bw * 1.6) * (1.0-in_outer);
    float in_inner  = (1.0-in_outer) * (1.0-in_margin);
    float title_bar   = step(cuv.y, 0.11) * in_inner;
    float number_bar  = step(0.91, cuv.y)  * in_inner;
    float image_field = in_inner * (1.0-title_bar) * (1.0-number_bar);

    // ── Palette ───────────────────────────────────────────────────────────────
    vec3 VOID    = u_ground_color;      // near-black #1C1C1C
    vec3 GOLD    = mix(vec3(0.75, 0.55, 0.08), vec3(1.0, 0.80, 0.0), u_gold_intensity);
    vec3 MAGENTA = vec3(0.545, 0.0, 0.545);
    vec3 DBLUE   = u_sky_color;         // dark blue #00008B
    vec3 WHITE   = vec3(0.95, 0.93, 0.85);

    vec3 col = vec3(0.03);
    col = mix(col, VOID, mask);  // card base: near-black void

    // ── Void radiance: subtle radial glow from card center ───────────────────
    {
        float glow = 1.0 - length((cuv - 0.5) * vec2(1.0, 1.73));
        glow = clamp(glow * 0.8, 0.0, 1.0) * 0.22;
        col = mix(col, GOLD * 0.35, mask * image_field * glow * u_gold_intensity);
    }

    // ── Star field background (Thoth has stars everywhere) ───────────────────
    {
        vec2 sg = cuv * vec2(11.0, 17.0);
        vec2 sc = floor(sg);
        vec2 sf = fract(sg);
        float h = hash(sc);
        if(h > 1.0 - u_symbol_density * 0.28){
            float sz = 0.12 + hash(sc + 7.3) * 0.10;
            float s = smoothstep(sz, 0.0, length(sf - 0.5));
            float flicker = 0.65 + 0.35 * sin(u_time * (1.5 + h * 2.0) + h * 6.28);
            col = mix(col, WHITE * flicker, mask * image_field * s * 0.5);
        }
    }

    // Card centre in image-field space
    float ify = (cuv.y - 0.11) / 0.80;
    vec2  img_c = vec2(0.5, ify * 0.80 + 0.11); // ~0.5
    vec2  cent = cuv - vec2(0.5, 0.50);

    // ── Outer planetary ring ──────────────────────────────────────────────────
    {
        float ring = glyphRing(cent, 0.34, 12);
        col = mix(col, GOLD * 0.65, mask * image_field * ring * u_gold_intensity);
    }

    // ── Tree of Life ─────────────────────────────────────────────────────────
    {
        float tree = treeOfLife(cent, 0.75);
        col = mix(col, GOLD, mask * image_field * tree * u_gold_intensity);
    }

    // ── Central hexagram ─────────────────────────────────────────────────────
    {
        float hex = hexagram(cent, 0.12);
        col = mix(col, GOLD, mask * image_field * hex * u_gold_intensity);
        // Inner triangle fill tints
        float up_tri = smoothstep(0.003, -0.001, sdTriangle(cent, 0.10));
        col = mix(col, DBLUE * 0.9, mask * image_field * up_tri * 0.65);
        float dn_tri = smoothstep(0.003, -0.001, sdTriangle(vec2(cent.x, -cent.y), 0.10));
        col = mix(col, MAGENTA * 0.7, mask * image_field * dn_tri * 0.65);
    }

    // ── Pentagram (outer, rotated) ────────────────────────────────────────────
    {
        float pen = pentagram(cent, 0.27);
        col = mix(col, MAGENTA * 0.75, mask * image_field * pen * u_gold_intensity * 0.7);
    }

    // ── Inner planetary circle with second set of tick marks ─────────────────
    {
        float ir = glyphRing(cent, 0.18, 7);
        col = mix(col, DBLUE * 1.2 + GOLD * 0.3, mask * image_field * ir * u_gold_intensity * 0.8);
    }

    // ── Lightning flash / path of the Fool ───────────────────────────────────
    {
        float lf = lightningPath(cent);
        col = mix(col, WHITE * 0.9, mask * image_field * lf * u_symbol_density * 0.7);
    }

    // ── Scattered symbol density layer: small crosses ─────────────────────────
    {
        float cnt = u_symbol_density * 8.0;
        for(float si = 0.0; si < 8.0; si++){
            if(si >= cnt) break;
            float h = hash1(si * 11.7);
            float h2 = hash1(si * 19.3 + 2.2);
            vec2 sp = vec2(0.08 + h * 0.84, 0.13 + h2 * 0.74);
            vec2 pp = cuv - sp;
            float cross_h = smoothstep(0.003, 0.0, sdBox(pp, vec2(0.018, 0.004)));
            float cross_v = smoothstep(0.003, 0.0, sdBox(pp, vec2(0.004, 0.018)));
            col = mix(col, GOLD * 0.6, mask * image_field * max(cross_h, cross_v) * u_gold_intensity * 0.5);
        }
    }

    // ── Animated energy pulse on hexagram ────────────────────────────────────
    {
        float pulse = sin(u_time * 1.2) * 0.5 + 0.5;
        float pulse_ring = smoothstep(0.008, 0.0, abs(sdCircle(cent, 0.13 + pulse * 0.03)));
        col = mix(col, GOLD * 0.5, mask * image_field * pulse_ring * u_gold_intensity * 0.4);
    }

    // ── Border: thin double gold line ─────────────────────────────────────────
    {
        float outer_line = smoothstep(0.003, 0.001, abs(edge - bw));
        float inner_line = smoothstep(0.0022, 0.001, abs(edge - bw * 1.6));
        col = mix(col, GOLD, mask * (outer_line + inner_line) * u_gold_intensity);
        // Thin margin strip
        col = mix(col, VOID * 1.4, mask * in_margin);
    }

    // ── Title bar ─────────────────────────────────────────────────────────────
    col = mix(col, VOID * 0.7, mask * title_bar);
    float ttext = smoothstep(0.003, 0.0, abs(cuv.y - 0.054) - 0.022)
                * smoothstep(0.005, 0.0, abs(cuv.x - 0.5)   - 0.27);
    col = mix(col, GOLD, mask * title_bar * ttext * u_gold_intensity);

    // ── Number bar ─────────────────────────────────────────────────────────────
    col = mix(col, VOID * 0.7, mask * number_bar);
    float ntext = smoothstep(0.003, 0.0, abs(cuv.y - 0.952) - 0.018)
                * smoothstep(0.005, 0.0, abs(cuv.x - 0.5)   - 0.08);
    col = mix(col, GOLD, mask * number_bar * ntext * u_gold_intensity);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}

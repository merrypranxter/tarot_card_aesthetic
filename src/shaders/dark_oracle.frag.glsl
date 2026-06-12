// Dark Oracle — Black Ground, Gold Mark-Making
// Aesthetic: DARK_ORACLE
// Palette: Black #0D0D0D, Aged Gold #C0A870, Dark Red #8B1C1C
//
// Sky grammar: no sky — there is only the ground. The black is everything: the void,
//   the oracle's silence, the space between the words. Gold is fire pulled from dark.
//   Dark red is blood memory, warning, the ancient wound.
//
// Visual vocabulary:
//   Distressed gold borders — irregular, hand-worn, not machine-perfect
//   Central cross or rune — the mark, the seal, the signature
//   Drip / splatter texture — urgency, the oracle speaks fast
//   Rough spiral — time, transformation, the inward journey
//   Eye — the all-seeing, the oracle's eye
//   Scratched lines — age, palimpsest, layers of reading
//
// Structure: thick rough gold border (distressed) → black void field →
//            central mark (cross/rune/eye) → gold drip texture →
//            dark red accent marks → title (gold, all caps, archaic serif) →
//            number (gold, Roman, top centre)

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
float smoothHash(vec2 p){
    vec2 i=floor(p); vec2 f=fract(p);
    f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
float sdCircle(vec2 p, float r){ return length(p) - r; }
float sdBox(vec2 p, vec2 b){ vec2 d=abs(p)-b; return length(max(d,0.0))+min(max(d.x,d.y),0.0); }
float sdLine(vec2 p, vec2 a, vec2 b){
    vec2 pa=p-a, ba=b-a;
    float h=clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0);
    return length(pa-ba*h);
}
float sdTriangle(vec2 p, float r){
    const float k = 1.7320508;
    p.x = abs(p.x) - r;
    p.y = p.y + r / k;
    if(p.x + k*p.y > 0.0) p = vec2(p.x - k*p.y, -k*p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0*r, 0.0);
    return -length(p) * sign(p.y);
}

// Distressed / rough edge noise
float distress(vec2 p, float scale){ return smoothHash(p * scale) * 0.5 + 0.5; }

// Rough stroke: line with noise displacement
float roughStroke(vec2 p, vec2 a, vec2 b, float w, float noise_scale){
    // Displace p by noise
    vec2 n = vec2(smoothHash(p * noise_scale + 0.5), smoothHash(p * noise_scale * 1.3 + 1.7)) * 0.006;
    float d = sdLine(p + n, a, b);
    return smoothstep(w, w * 0.3, d);
}

// Archaic cross
float archCross(vec2 p, float size){
    float h = roughStroke(p, vec2(-size, 0.0), vec2(size, 0.0), 0.012, 18.0);
    float v = roughStroke(p, vec2(0.0, -size), vec2(0.0, size), 0.012, 18.0);
    // Serifs at ends
    vec2 ends[4];
    ends[0] = vec2(-size, 0.0); ends[1] = vec2(size, 0.0);
    ends[2] = vec2(0.0, -size); ends[3] = vec2(0.0, size);
    float serifs = 0.0;
    for(int i=0; i<4; i++){
        float se = roughStroke(p, ends[i] - vec2(ends[i].y, ends[i].x)*0.012,
                                  ends[i] + vec2(ends[i].y, ends[i].x)*0.012, 0.006, 22.0);
        serifs = max(serifs, se);
    }
    return max(max(h, v), serifs);
}

// Eye glyph (almond + pupil + iris)
float eyeGlyph(vec2 p, float w, float h_r){
    // Almond outline: intersection of two circles
    float c1 = sdCircle(p - vec2(-w*0.5, 0.0), w * 0.7);
    float c2 = sdCircle(p - vec2( w*0.5, 0.0), w * 0.7);
    float almond_outer = abs(max(c1, c2));
    float almond = smoothstep(0.005, 0.001, almond_outer);
    // Iris circle
    float iris = smoothstep(0.003, 0.001, abs(sdCircle(p, w * 0.26)));
    // Pupil
    float pupil = smoothstep(w*0.13, 0.0, length(p));
    return max(max(almond, iris), pupil);
}

// Rough spiral (archimedes approximation)
float roughSpiral(vec2 p, float scale, float tightness){
    float r = length(p);
    float a = atan(p.y, p.x);
    float spiral_r = (a + 3.14159) / (2.0 * 3.14159) * tightness;
    float d = abs(r - spiral_r * scale);
    for(int i = 1; i <= 3; i++){
        float a2 = a + float(i) * 6.28318;
        float r2 = (a2 + 3.14159) / (2.0 * 3.14159) * tightness * scale;
        d = min(d, abs(r - r2));
    }
    return smoothstep(0.006, 0.001, d);
}

// Drip: vertical stroke that tapers (simulates paint drip)
float drip(vec2 p, float x, float y_start, float len){
    float taper = 1.0 - clamp((p.y - y_start) / (-len), 0.0, 1.0);
    float w = 0.006 + taper * 0.003;
    float d = sdBox(p - vec2(x, y_start - len*0.5), vec2(w, len*0.5));
    return smoothstep(0.003, -0.001, d);
}

void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float sar = u_resolution.x / u_resolution.y;

    float ch = 0.88;
    float cw = ch / (1.73 * sar);
    vec2 cuv = (uv - 0.5 + vec2(cw, ch) * 0.5) / vec2(cw, ch);
    float mask = step(0.0, cuv.x) * step(cuv.x, 1.0) * step(0.0, cuv.y) * step(cuv.y, 1.0);

    float bw    = u_border_weight * 0.055 + 0.028;
    float edge  = min(min(cuv.x, 1.0-cuv.x), min(cuv.y, 1.0-cuv.y));
    float in_outer  = step(edge, bw);
    float in_margin = step(edge, bw * 1.5) * (1.0-in_outer);
    float in_inner  = (1.0-in_outer) * (1.0-in_margin);
    float title_bar   = step(cuv.y, 0.12) * in_inner;
    float number_bar  = step(0.90, cuv.y)  * in_inner;
    float image_field = in_inner * (1.0-title_bar) * (1.0-number_bar);

    // ── Palette ───────────────────────────────────────────────────────────────
    vec3 VOID   = u_ground_color;  // near-black
    vec3 GOLD   = mix(vec3(0.6, 0.45, 0.12), vec3(0.75, 0.66, 0.43), u_gold_intensity);
    vec3 DRED   = u_sky_color;     // dark red
    vec3 EMBER  = mix(DRED, GOLD, 0.4);

    vec3 col = vec3(0.04);
    col = mix(col, VOID, mask);

    // ── Subtle void texture (micro noise) ────────────────────────────────────
    {
        float n = smoothHash(cuv * 85.0) * 0.025;
        col = mix(col, VOID + vec3(n), mask * image_field);
    }

    vec2 cent = cuv - vec2(0.5, 0.5);

    // ── Gold dust / particle scatter in background ────────────────────────────
    {
        vec2 pg = cuv * vec2(28.0, 42.0);
        vec2 pc = floor(pg);
        float h = hash(pc);
        if(h > 1.0 - u_symbol_density * 0.22){
            vec2 pf = fract(pg) - 0.5;
            float pt_r = 0.08 + hash(pc+3.1) * 0.10;
            float pt = smoothstep(pt_r, 0.0, length(pf));
            float flicker = 0.5 + 0.5 * sin(u_time * (0.8 + h * 1.5) + h * 6.28);
            col = mix(col, GOLD * flicker * 0.6, mask * image_field * pt * u_gold_intensity);
        }
    }

    // ── Central archaic cross ─────────────────────────────────────────────────
    {
        float cross_sz = 0.22;
        float cr = archCross(cent, cross_sz);
        col = mix(col, GOLD, mask * image_field * cr * u_gold_intensity);

        // Dark red inner cross (slightly smaller, offset)
        float cr_red = archCross(cent + vec2(0.003, -0.002), cross_sz * 0.85);
        col = mix(col, DRED * 0.9, mask * image_field * cr_red * 0.7);
    }

    // ── Eye glyph (centre) ────────────────────────────────────────────────────
    {
        float ey = eyeGlyph(cent, 0.09, 0.04);
        col = mix(col, GOLD, mask * image_field * ey * u_gold_intensity);
        // Pupil fill in dark red
        float pupil = smoothstep(0.022, 0.0, length(cent));
        col = mix(col, DRED, mask * image_field * pupil * 0.8);
    }

    // ── Rough spiral ─────────────────────────────────────────────────────────
    {
        float sp = roughSpiral(cent, 0.038, 1.0) * u_symbol_density;
        col = mix(col, GOLD * 0.7, mask * image_field * sp * u_gold_intensity * 0.7);
    }

    // ── Drip marks ───────────────────────────────────────────────────────────
    {
        float cnt = u_symbol_density * 6.0;
        for(float di = 0.0; di < 6.0; di++){
            if(di >= cnt) break;
            float h = hash1(di * 7.3 + 0.5);
            float x = 0.12 + h * 0.76;
            float len = 0.04 + hash1(di * 13.1) * 0.06;
            float y_start = 0.75 + hash1(di * 19.7) * 0.06;
            float d = drip(cuv, x, y_start, len);
            col = mix(col, DRED * 0.85, mask * image_field * d * 0.8);
        }
    }

    // ── Rune scratch lines (angled archaic marks) ─────────────────────────────
    {
        float cnt = u_symbol_density * 5.0;
        for(float ri = 0.0; ri < 5.0; ri++){
            if(ri >= cnt) break;
            float h = hash1(ri * 11.1 + 2.5);
            float h2 = hash1(ri * 17.3 + 5.1);
            vec2 rc = vec2(0.15 + h * 0.70, 0.20 + h2 * 0.60);
            float angle = hash1(ri * 23.7) * 3.14159;
            vec2 d0 = vec2(cos(angle), sin(angle)) * 0.035;
            float rune = roughStroke(cuv, rc - d0, rc + d0, 0.004, 25.0);
            col = mix(col, EMBER, mask * image_field * rune * 0.55);
        }
    }

    // ── Triangle outline (pointing down — water/shadow) ───────────────────────
    {
        float tri_d = abs(sdTriangle(vec2(cent.x, -cent.y + 0.05), 0.19));
        float tri = smoothstep(0.006, 0.002, tri_d);
        col = mix(col, GOLD * 0.55, mask * image_field * tri * u_gold_intensity * 0.7);
    }

    // ── Border: thick, distressed, aged gold ─────────────────────────────────
    {
        // Base gold border
        float noise_offset = smoothHash(cuv * 32.0) * 0.006;
        float rough_edge   = edge + noise_offset - 0.003;
        float border       = step(rough_edge, bw);
        col = mix(col, GOLD * 0.6, mask * border * u_gold_intensity);

        // Dark red inner accent strip
        float inner_strip = step(edge, bw * 1.5) - step(edge, bw * 1.5 - 0.006);
        col = mix(col, DRED * 0.75, mask * inner_strip * 0.7);

        // Inner gold line
        float iline = smoothstep(0.0025, 0.0, abs(edge - bw * 1.5));
        col = mix(col, GOLD * 0.8, mask * iline * u_gold_intensity);
    }

    // ── Title bar ─────────────────────────────────────────────────────────────
    col = mix(col, VOID * 0.5, mask * title_bar);
    float ttext = smoothstep(0.003, 0.0, abs(cuv.y - 0.058) - 0.022)
                * smoothstep(0.005, 0.0, abs(cuv.x - 0.5)   - 0.26);
    col = mix(col, GOLD * 0.85, mask * title_bar * ttext * u_gold_intensity);

    // ── Number bar ─────────────────────────────────────────────────────────────
    col = mix(col, VOID * 0.5, mask * number_bar);
    float ntext = smoothstep(0.003, 0.0, abs(cuv.y - 0.949) - 0.018)
                * smoothstep(0.005, 0.0, abs(cuv.x - 0.5)   - 0.072);
    col = mix(col, GOLD * 0.85, mask * number_bar * ntext * u_gold_intensity);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}

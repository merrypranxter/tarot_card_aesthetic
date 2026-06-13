// Marseille Flat — Pre-Rider Geometric Pip Arrangement
// Aesthetic: MARSEILLE_FLAT
// Palette: Red #FF4500, Yellow #FFD700, Blue #000080, Wheat #F5DEB3
//
// Sky grammar: none — the Marseille tradition has no sky. The card is pure pattern.
//   The image field is decorative, not illustrative. Numbered cards show only pips.
//   Court cards show flat heraldic figures, no landscape behind them.
//
// Structure: thick alternating red/blue border → thin yellow line → wheat field →
//            geometric pip rows → title (red band) → number (blue band)

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

float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float sdBox(vec2 p, vec2 b){ vec2 d = abs(p)-b; return length(max(d,0.0))+min(max(d.x,d.y),0.0); }
float sdCircle(vec2 p, float r){ return length(p) - r; }

// Cup / chalice pip (Coupe)
float cup(vec2 p, float sz){
    float body  = smoothstep(0.004, -0.002, sdBox(p - vec2(0.0,  sz*0.18), vec2(sz*0.46, sz*0.32)));
    float stem  = smoothstep(0.003, -0.001, sdBox(p - vec2(0.0, -sz*0.20), vec2(sz*0.07, sz*0.17)));
    float base  = smoothstep(0.003, -0.001, sdBox(p - vec2(0.0, -sz*0.39), vec2(sz*0.28, sz*0.06)));
    return max(max(body, stem), base);
}

// Sword pip (Épée)
float sword(vec2 p, float sz){
    float blade  = smoothstep(0.003, -0.001, sdBox(p - vec2(0.0,  sz*0.12), vec2(sz*0.035, sz*0.52)));
    float guard  = smoothstep(0.003, -0.001, sdBox(p - vec2(0.0, -sz*0.10), vec2(sz*0.26, sz*0.055)));
    float handle = smoothstep(0.003, -0.001, sdBox(p - vec2(0.0, -sz*0.28), vec2(sz*0.055, sz*0.15)));
    return max(max(blade, guard), handle);
}

// Wand / baton pip with leaf nodes
float wand(vec2 p, float sz){
    float staff = smoothstep(0.003, -0.001, sdBox(p, vec2(sz*0.06, sz*0.58)));
    float l1    = smoothstep(0.005, -0.001, sdCircle(p - vec2( sz*0.11,  sz*0.18), sz*0.095));
    float l2    = smoothstep(0.005, -0.001, sdCircle(p - vec2(-sz*0.11, -sz*0.05), sz*0.095));
    float l3    = smoothstep(0.005, -0.001, sdCircle(p - vec2( sz*0.11, -sz*0.28), sz*0.08));
    return max(staff, max(max(l1, l2), l3));
}

// Pentacle (Denier) — circle with 5 inner dots
float pentacle(vec2 p, float r){
    float ring = smoothstep(0.004, 0.001, abs(sdCircle(p, r)));
    float dots = 0.0;
    for(int i = 0; i < 5; i++){
        float a = float(i) * 1.25664 - 1.5708;
        vec2 pt = vec2(cos(a), sin(a)) * r * 0.58;
        dots = max(dots, smoothstep(0.010, 0.0, sdCircle(p - pt, r * 0.14)));
    }
    return max(ring, dots);
}

// Fleur-de-lis / central decorative divider
float fleur(vec2 p, float sz){
    float center = smoothstep(0.005, -0.001, sdCircle(p, sz * 0.3));
    float left   = smoothstep(0.005, -0.001, sdCircle(p - vec2(-sz*0.45, sz*0.1), sz * 0.22));
    float right  = smoothstep(0.005, -0.001, sdCircle(p - vec2( sz*0.45, sz*0.1), sz * 0.22));
    float top    = smoothstep(0.005, -0.001, sdCircle(p - vec2( 0.0, sz*0.52), sz * 0.22));
    float stem   = smoothstep(0.003, -0.001, sdBox(p - vec2(0.0, -sz*0.3), vec2(sz*0.06, sz*0.35)));
    return max(max(max(center, left), max(right, top)), stem);
}

void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float sar = u_resolution.x / u_resolution.y;

    float ch = 0.88;
    float cw = ch / (1.73 * sar);
    vec2 cuv = (uv - 0.5 + vec2(cw, ch) * 0.5) / vec2(cw, ch);
    float mask = step(0.0, cuv.x) * step(cuv.x, 1.0) * step(0.0, cuv.y) * step(cuv.y, 1.0);

    float bw    = u_border_weight * 0.045 + 0.025;
    float edge  = min(min(cuv.x, 1.0 - cuv.x), min(cuv.y, 1.0 - cuv.y));
    float in_outer  = step(edge, bw);
    float in_margin = step(edge, bw * 1.7) * (1.0 - in_outer);
    float in_inner  = (1.0 - in_outer) * (1.0 - in_margin);
    float title_bar   = step(cuv.y, 0.12)  * in_inner;
    float number_bar  = step(0.90, cuv.y)  * in_inner;
    float image_field = in_inner * (1.0 - title_bar) * (1.0 - number_bar);

    // ── Palette ───────────────────────────────────────────────────────────────
    vec3 WHEAT  = u_ground_color;
    vec3 RED    = vec3(1.0, 0.27, 0.0);
    vec3 YELLOW = vec3(1.0, 0.85, 0.0);
    vec3 BLUE   = vec3(0.0, 0.0, 0.50);
    vec3 BLACK  = vec3(0.05);
    vec3 GOLD   = mix(vec3(0.78, 0.62, 0.12), YELLOW, u_gold_intensity);

    vec3 col = vec3(0.06);
    col = mix(col, WHEAT, mask);  // card base

    // ── Wheat background with subtle hatching ─────────────────────────────────
    {
        float hatch = step(0.5, fract(cuv.x * 22.0 + cuv.y * 14.0));
        vec3 bg = mix(WHEAT, WHEAT * 0.97, hatch * 0.25);
        col = mix(col, bg, mask * image_field * 0.85);
    }

    // ── Pip arrangement (standard Marseille layout, up to 10 pips) ───────────
    {
        int np = clamp(u_arcana_number, 1, 10);
        float sz = 0.040;

        // Standard suit pip positions for 1–10:
        //   These are (x_offset_from_center, y_in_image_field) pairs.
        //   We mirror vertically for rows above and below center.
        // Using a simplified 2-column layout (left=−0.20, right=+0.20, center=0.0)
        // Rows evenly spaced in [0.18, 0.82] of image field

        float ify_start = 0.13 + 0.115;  // bottom of image field in cuv
        float ify_range = 0.77 * 0.88;   // range in cuv

        // X positions: left-center-right
        float xs[3];
        xs[0] = 0.22; xs[1] = 0.50; xs[2] = 0.78;

        // Row y positions (evenly divided by number of pips, simplified)
        int rows = max(1, (np + 1) / 2);
        float dy = ify_range / float(rows + 1);

        int drawn = 0;
        for(int row = 0; row < 5; row++){
            if(drawn >= np) break;
            float py = ify_start + float(row + 1) * dy;
            int cols = (row == rows / 2 && (np % 2 == 1)) ? 1 : 2;
            for(int c = 0; c < 2; c++){
                if(drawn >= np) break;
                float px = (cols == 1) ? 0.5 : (c == 0 ? 0.28 : 0.72);
                vec2 pp = cuv - vec2(px, py);

                float pip = cup(pp, sz);
                col = mix(col, BLUE, mask * image_field * pip);
                // Outline
                float out_pip = smoothstep(0.003, 0.0, abs(sdBox(pp - vec2(0.0, sz*0.18), vec2(sz*0.46, sz*0.32))) - 0.003);
                col = mix(col, BLACK, mask * image_field * out_pip * u_outline_weight * 0.6);
                drawn++;
            }
        }
    }

    // ── Central divider / fleur-de-lis ───────────────────────────────────────
    {
        float f = fleur(cuv - vec2(0.5, 0.50), 0.055);
        col = mix(col, RED, mask * image_field * f);
    }

    // ── Decorative side panels (Marseille: thin repeated vegetal scrollwork) ─
    {
        // Vertical scroll at x=0.10 and x=0.90
        float scroll_x0 = abs(cuv.x - 0.13);
        float scroll_x1 = abs(cuv.x - 0.87);
        float scroll_t  = fract(cuv.y * 12.0);
        float scroll = step(scroll_x0, 0.018) + step(scroll_x1, 0.018);
        float leaf_mask = sin(scroll_t * 6.28) * 0.5 + 0.5;
        col = mix(col, RED * 0.75, mask * image_field * scroll * leaf_mask * 0.5);
    }

    // ── Border: alternating red/blue segments ─────────────────────────────────
    {
        float seg = floor(cuv.x * 10.0 + cuv.y * 8.0);
        vec3 seg_col = mix(RED, BLUE, mod(seg, 2.0));
        col = mix(col, seg_col, mask * in_outer);

        // Inner margin: thin yellow band
        float yline = smoothstep(0.0022, 0.0, abs(edge - bw * 1.7));
        col = mix(col, YELLOW, mask * yline * 0.9);

        // Corner circle rosettes
        vec2 corn[4];
        corn[0] = vec2(bw, bw); corn[1] = vec2(1.0-bw, bw);
        corn[2] = vec2(bw, 1.0-bw); corn[3] = vec2(1.0-bw, 1.0-bw);
        for(int ci = 0; ci < 4; ci++){
            float cr = sdCircle(cuv - corn[ci], bw * 0.55);
            col = mix(col, YELLOW, mask * smoothstep(0.003, 0.0, abs(cr)));
        }
    }

    // ── Title bar (red with yellow/gold text block) ───────────────────────────
    col = mix(col, RED * 0.72, mask * title_bar * 0.9);
    float ttext = smoothstep(0.0025, 0.0, abs(cuv.y - 0.058) - 0.024)
                * smoothstep(0.004,  0.0, abs(cuv.x - 0.5)   - 0.30);
    col = mix(col, YELLOW, mask * title_bar * ttext);

    // ── Number bar (blue) ──────────────────────────────────────────────────────
    col = mix(col, BLUE * 0.8, mask * number_bar * 0.85);
    float ntext = smoothstep(0.0025, 0.0, abs(cuv.y - 0.945) - 0.018)
                * smoothstep(0.004,  0.0, abs(cuv.x - 0.5)   - 0.065);
    col = mix(col, YELLOW, mask * number_bar * ntext);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}

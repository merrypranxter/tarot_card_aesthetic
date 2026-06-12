// The Fool — Major Arcana 0 — Rider-Waite Revival
// Card: 0 — THE FOOL
// Aesthetic: RIDER_WAITE_REVIVAL
// Palette: Cream, Gold, White, Deep Red, Midnight Blue, Green
//
// Sky grammar: YELLOW — pure day consciousness. The sun is at its height.
//   The Fool walks into the sky itself. The cliff does not matter.
//   Yellow = solar will, the step before thought, the divine beginner.
//
// Card imagery (Pamela Coleman Smith, 1909):
//   - Blazing sun upper right
//   - White peak mountains, distant
//   - Cliff edge (the precipice)
//   - Figure: motley costume, one white rose (purity of intent), bindle/staff
//   - Small white dog at his heels (instinct, the earthly, warning)
//   - Looking UP, not at his feet
//
// Symbolic vocabulary:
//   White rose = purity of intent (NOT innocence — intent)
//   Staff = will, journey, the masculine
//   Bindle bag = the accumulated self, all one's things
//   Dog = the lower nature, earthly wisdom, loyal warning
//   Cliff = the known edge of the known world
//   Sun = consciousness, the solar logos, the reason to step

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
float sdCircle(vec2 p, float r){ return length(p)-r; }
float sdBox(vec2 p, vec2 b){ vec2 d=abs(p)-b; return length(max(d,0.0))+min(max(d.x,d.y),0.0); }
float sdLine(vec2 p, vec2 a, vec2 b){
    vec2 pa=p-a, ba=b-a;
    float h=clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0);
    return length(pa-ba*h);
}

float star8(vec2 p, float r){
    vec2 q=abs(p);
    float d=min(max(q.x,q.y),(q.x+q.y)*0.707);
    return smoothstep(r,r*0.45,d);
}
float sdDiamond(vec2 p, float s){ return (abs(p.x)+abs(p.y))/s - 1.0; }
float cornerDeco(vec2 p, float sz){
    float d=min(abs(sdDiamond(p,sz)),abs(sdDiamond(p,sz*0.55)));
    return smoothstep(0.005,0.001,d);
}

// Rose: circle ring + 8 petals
float whiteRose(vec2 p, float r){
    float ring = smoothstep(0.005, 0.001, abs(sdCircle(p, r)));
    float petals = 0.0;
    for(int i=0; i<5; i++){
        float a = float(i) * 1.25664;
        vec2 pc = vec2(cos(a), sin(a)) * r * 0.55;
        petals = max(petals, smoothstep(0.007, -0.001, sdCircle(p - pc, r * 0.35)));
    }
    float center = smoothstep(0.005, -0.001, sdCircle(p, r * 0.22));
    return max(max(ring, petals), center);
}

void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float sar = u_resolution.x / u_resolution.y;

    float ch = 0.88;
    float cw = ch / (1.73 * sar);
    vec2 cuv = (uv - 0.5 + vec2(cw, ch) * 0.5) / vec2(cw, ch);
    float mask = step(0.0,cuv.x)*step(cuv.x,1.0)*step(0.0,cuv.y)*step(cuv.y,1.0);

    float bw   = u_border_weight * 0.04 + 0.022;
    float edge = min(min(cuv.x, 1.0-cuv.x), min(cuv.y, 1.0-cuv.y));
    float in_outer  = step(edge, bw);
    float in_margin = step(edge, bw*1.9) * (1.0-in_outer);
    float in_inner  = (1.0-in_outer) * (1.0-in_margin);
    float title_bar   = step(cuv.y, 0.115) * in_inner;
    float number_bar  = step(0.905, cuv.y)  * in_inner;
    float image_field = in_inner * (1.0-title_bar) * (1.0-number_bar);

    // Palette
    vec3 CREAM = u_ground_color;
    vec3 GOLD  = mix(vec3(0.75,0.60,0.15), vec3(1.0,0.85,0.0), u_gold_intensity);
    vec3 DRED  = vec3(0.545, 0.0, 0.0);
    vec3 MBLUE = vec3(0.098, 0.098, 0.44);
    vec3 GREEN = vec3(0.133, 0.545, 0.133);
    vec3 WHITE = vec3(0.96, 0.96, 0.94);
    vec3 SKY   = u_sky_color;  // yellow

    float ify = (cuv.y - 0.115) / 0.79;

    // ── Sky: pure blazing yellow ──────────────────────────────────────────────
    vec3 img = mix(SKY * 0.92, SKY, smoothstep(0.35, 0.75, ify));
    // Horizon glow (creamy warmth near ground line)
    img = mix(img, CREAM * 0.95, smoothstep(0.28, 0.0, ify) * 0.6);

    // ── Distant snow-capped mountains ─────────────────────────────────────────
    {
        // Main mountain profile
        float m1 = 0.46 - smoothHash(vec2(cuv.x * 2.8, 0.0)) * 0.08;
        float m2 = 0.42 - smoothHash(vec2(cuv.x * 4.2 + 1.5, 0.0)) * 0.06;
        float mtn = max(smoothstep(0.004, -0.004, ify - m1),
                        smoothstep(0.004, -0.004, ify - m2));
        img = mix(img, WHITE * 0.88 + MBLUE * 0.08, mtn * 0.9);
        // Snow caps: top portion lighter
        float snow = max(smoothstep(0.006, -0.002, ify - (m1 + 0.03)),
                         smoothstep(0.006, -0.002, ify - (m2 + 0.025)));
        img = mix(img, WHITE, snow);
    }

    // ── Cliff edge (rocky, sharp drop at about cuv.y=0.30) ───────────────────
    {
        float cliff_y = 0.30;
        // Cliff top: green
        float cliff_top = smoothstep(0.012, -0.004, cuv.y - cliff_y);
        img = mix(img, GREEN * 0.55 + CREAM * 0.2, cliff_top * 0.85);
        // Cliff face: rocky brown/grey (right side where Fool stands)
        float cliff_face = step(0.55, cuv.x) * smoothstep(0.0, -0.012, cuv.y - cliff_y)
                         * smoothstep(-0.10, 0.0, cuv.y - cliff_y + 0.12);
        img = mix(img, CREAM * 0.65 + MBLUE * 0.2, cliff_face * 0.7);
    }

    // ── Sun (upper right, large, blazing) ─────────────────────────────────────
    {
        vec2 sun_c = vec2(0.76, 0.78);
        float sun_r = 0.072;
        float sun_d = sdCircle(cuv - sun_c, sun_r);
        // Glow
        img = mix(img, SKY * 1.08, smoothstep(0.14, 0.0, abs(sun_d + 0.07)) * 0.45);
        // Disk
        img = mix(img, GOLD, smoothstep(0.004, -0.002, sun_d) * u_gold_intensity);
        // Face (crude: 2 eye dots, smile arc)
        float eye1 = smoothstep(0.008, 0.0, sdCircle(cuv - sun_c - vec2(-0.022, 0.012), 0.010));
        float eye2 = smoothstep(0.008, 0.0, sdCircle(cuv - sun_c - vec2( 0.022, 0.012), 0.010));
        float smile_d = abs(sdCircle(cuv - sun_c - vec2(0.0, -0.008), 0.030)) ;
        float smile = smoothstep(0.006, 0.001, smile_d) * step(0.0, -(cuv.y - sun_c.y + 0.008));
        img = mix(img, CREAM * 0.6, (eye1 + eye2 + smile) * step(0.0, -sun_d));
        // Rays (12)
        for(int ri=0; ri<12; ri++){
            float a = float(ri) * 0.5236;
            vec2 dir = vec2(cos(a), sin(a));
            vec2 pp  = cuv - sun_c;
            float along = dot(pp, dir);
            float perp  = abs(dot(pp, vec2(-dir.y, dir.x)));
            float ray = smoothstep(0.005, 0.0, perp) * step(sun_r + 0.004, along) * step(along, sun_r + 0.046);
            img = mix(img, GOLD, ray * u_gold_intensity);
        }
    }

    // ── 8-point stars ─────────────────────────────────────────────────────────
    {
        vec2 sg = cuv * vec2(9.0, 11.0);
        vec2 sc = floor(sg); vec2 sf = fract(sg);
        float h = hash(sc);
        if(h > 1.0 - u_symbol_density * 0.28 && ify > 0.55){
            float s = star8(sf - 0.5, 0.20);
            img += GOLD * s * u_gold_intensity * 0.7 * smoothstep(0.55, 0.65, ify);
        }
    }

    // ── The Fool figure (walking, looking up-left) ────────────────────────────
    {
        // Head
        vec2 hc = vec2(0.50, 0.60);
        float head = smoothstep(0.004, -0.002, sdCircle(cuv - hc, 0.038));
        img = mix(img, CREAM, head);

        // Jester hat (tall, 3 points)
        for(int hi=0; hi<3; hi++){
            float hx = (float(hi)-1.0) * 0.028;
            float hy = 0.044 + float(hi%2) * 0.022;
            float pt = smoothstep(0.008, -0.001, sdCircle(cuv - hc - vec2(hx, hy), 0.020));
            img = mix(img, (hi==1) ? DRED : GOLD, pt * ((hi==1) ? 1.0 : u_gold_intensity));
        }

        // Motley tunic (mixed colors: red/white diamonds pattern)
        vec2 bc = vec2(0.50, 0.44);
        float body = smoothstep(0.004, -0.002, sdBox(cuv - bc, vec2(0.055, 0.075)));
        // Diamond pattern on tunic
        float dm_size = 0.022;
        vec2 dm_uv = cuv - bc;
        float dm_p = abs(dm_uv.x / dm_size) + abs(dm_uv.y / dm_size);
        float dm_pattern = mod(floor(dm_p), 2.0);
        img = mix(img, mix(DRED * 0.85, WHITE * 0.9, dm_pattern), body);

        // Outline
        float b_out = body * smoothstep(0.058, 0.050, sdBox(cuv - bc, vec2(0.055, 0.075)) + 0.004);
        img = mix(img, vec3(0.04), b_out * u_outline_weight * 12.0);

        // Head outline
        float h_out = head * smoothstep(0.040, 0.034, sdCircle(cuv - hc, 0.038) + 0.003);
        img = mix(img, vec3(0.04), h_out * u_outline_weight * 10.0);

        // Looking upward: face tilt
        // Eyes (angled toward sun)
        float e1 = smoothstep(0.006, 0.0, sdCircle(cuv - hc - vec2(0.012, 0.010), 0.007));
        float e2 = smoothstep(0.006, 0.0, sdCircle(cuv - hc - vec2(-0.008, 0.013), 0.007));
        img = mix(img, vec3(0.05), (e1+e2) * step(0.0, -sdCircle(cuv-hc, 0.038)));

        // Staff (diagonal, Fool holds it over shoulder)
        float staff = smoothstep(0.004, -0.001,
            sdLine(cuv, vec2(0.55, 0.30), vec2(0.60, 0.72)));
        img = mix(img, CREAM * 0.7, staff);
        img = mix(img, vec3(0.04), staff * 0.6 * u_outline_weight * 8.0);

        // Bindle (small circle at top of staff)
        float bindle = smoothstep(0.004, -0.001, sdCircle(cuv - vec2(0.60, 0.73), 0.022));
        img = mix(img, DRED * 0.7, bindle);

        // White rose (held in left hand area)
        vec2 rose_c = vec2(0.42, 0.40);
        float rose = whiteRose(cuv - rose_c, 0.022);
        img = mix(img, WHITE, rose * 0.9);
        img = mix(img, vec3(0.04), rose * smoothstep(0.023, 0.018, sdCircle(cuv-rose_c, 0.022)) * u_outline_weight * 8.0);
    }

    // ── Small white dog (lower right, barking upward) ─────────────────────────
    {
        vec2 dog_c = vec2(0.60, 0.31);
        float body  = smoothstep(0.004, -0.001, sdBox(cuv - dog_c, vec2(0.030, 0.022)));
        float head  = smoothstep(0.004, -0.001, sdCircle(cuv - dog_c - vec2(0.025, 0.018), 0.018));
        float ear   = smoothstep(0.004, -0.001, sdBox(cuv - dog_c - vec2(0.030, 0.034), vec2(0.007, 0.011)));
        float tail  = smoothstep(0.004, -0.001, sdBox(cuv - dog_c - vec2(-0.030, 0.015), vec2(0.006, 0.018)));
        float dog   = max(max(max(body, head), ear), tail);
        img = mix(img, WHITE * 0.92, dog);
        float dog_out = dog * smoothstep(0.033, 0.026, sdBox(cuv-dog_c, vec2(0.030,0.022)) + 0.003);
        img = mix(img, vec3(0.04), dog_out * u_outline_weight * 9.0);
    }

    // ── Border ────────────────────────────────────────────────────────────────
    float shimmer = sin(cuv.x*38.0 + u_time*0.5)*sin(cuv.y*38.0 + u_time*0.5)*0.5+0.5;
    vec3 border_col = mix(GOLD*0.65, GOLD, shimmer * u_gold_intensity);
    float iline = smoothstep(0.0028, 0.0, abs(edge - bw*1.9));
    float cdeco = 0.0;
    vec2 corn[4];
    corn[0]=vec2(bw*0.85,bw*0.85); corn[1]=vec2(1.0-bw*0.85,bw*0.85);
    corn[2]=vec2(bw*0.85,1.0-bw*0.85); corn[3]=vec2(1.0-bw*0.85,1.0-bw*0.85);
    for(int ci=0;ci<4;ci++) cdeco=max(cdeco,cornerDeco(cuv-corn[ci],bw*0.88));

    vec3 title_dark = MBLUE*0.45 + DRED*0.25;
    float ttext = smoothstep(0.0025,0.0,abs(cuv.y-0.057)-0.022)*smoothstep(0.004,0.0,abs(cuv.x-0.5)-0.28);
    float ntext = smoothstep(0.0025,0.0,abs(cuv.y-0.952)-0.018)*smoothstep(0.004,0.0,abs(cuv.x-0.5)-0.05);

    vec3 col = vec3(0.07);
    col = mix(col, CREAM, mask);
    col = mix(col, img,   mask * image_field);
    col = mix(col, title_dark,  mask * title_bar * 0.88);
    col = mix(col, GOLD,        mask * title_bar * ttext * u_gold_intensity);
    col = mix(col, title_dark*0.75, mask * number_bar * 0.55);
    col = mix(col, GOLD,        mask * number_bar * ntext * u_gold_intensity);
    col = mix(col, CREAM*0.95,  mask * in_margin);
    col = mix(col, border_col,  mask * in_outer);
    col = mix(col, GOLD*0.9,    iline * u_gold_intensity);
    col = mix(col, GOLD,        mask * cdeco * u_gold_intensity);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}

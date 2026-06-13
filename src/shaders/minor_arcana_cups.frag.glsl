// Ace of Cups — Minor Arcana, Cups Suit, Card 1 — Rider-Waite Revival
// Card: ACE OF CUPS
// Aesthetic: RIDER_WAITE_REVIVAL
// Palette: Cream, Gold, Blue (water sky), Deep Red, White
//
// Sky grammar: BLUE — water, the unconscious, emotion, the feminine receptive.
//   The Ace of Cups is pure potential in the emotional realm.
//   Blue sky = the vast inner ocean from which the cup rises.
//   The hand from the cloud = divine gift. You didn't earn the cup. It arrived.
//
// Card imagery (Pamela Coleman Smith, 1909):
//   - Disembodied hand emerging from a cloud (the divine gift)
//   - Ornate gold chalice (the cup) — 5 streams of water overflowing from it
//   - Dove descending into the cup carrying a wafer/disc (Holy Spirit / the gift)
//   - Water surface below (ripples, lotus blossoms)
//   - 25 Yod letters falling as drops (the blessings raining down)
//
// Symbolic vocabulary:
//   Cup       = the heart, the vessel, capacity for feeling
//   Water     = emotion, intuition, the unconscious, the soul
//   5 streams = the five senses, the five wounds, the five elements (in some readings)
//   Dove      = Holy Spirit, peace, the messenger
//   Wafer     = the Host, the sacred nourishment, spiritual food
//   Cloud     = the divine concealed, God-hand emerging from mystery
//   Lotus     = purity arising from the depths, enlightened emotion

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
float sdDiamond(vec2 p, float s){ return (abs(p.x)+abs(p.y))/s-1.0; }
float cornerDeco(vec2 p, float sz){
    float d=min(abs(sdDiamond(p,sz)),abs(sdDiamond(p,sz*0.55)));
    return smoothstep(0.005,0.001,d);
}
float star8(vec2 p, float r){
    vec2 q=abs(p); float d=min(max(q.x,q.y),(q.x+q.y)*0.707);
    return smoothstep(r,r*0.45,d);
}

// Ornate chalice (Cups Ace — wide bowl, narrowing stem, wide foot)
float chalice(vec2 p){
    // Bowl: wide at top, narrowing — approximate with trapezoid
    float bowl_top  = mix(0.085, 0.058, clamp((p.y - 0.03) / 0.12, 0.0, 1.0));
    float bowl      = smoothstep(0.004,-0.002, sdBox(p - vec2(0.0, 0.09), vec2(bowl_top, 0.09)));
    // Rim decorations (flared lip)
    float rim       = smoothstep(0.004,-0.001, sdBox(p - vec2(0.0, 0.185), vec2(0.094, 0.012)));
    // Stem (narrow)
    float stem      = smoothstep(0.003,-0.001, sdBox(p - vec2(0.0, -0.055), vec2(0.016, 0.065)));
    // Knop (bulge on stem)
    float knop      = smoothstep(0.004,-0.001, sdCircle(p - vec2(0.0, -0.02), 0.024));
    // Foot (wide, flared base)
    float foot      = smoothstep(0.004,-0.001, sdBox(p - vec2(0.0, -0.130), vec2(0.075, 0.015)));
    float foot2     = smoothstep(0.003,-0.001, sdBox(p - vec2(0.0, -0.118), vec2(0.055, 0.008)));
    return max(max(max(max(max(bowl, rim), stem), knop), foot), foot2);
}

// Water stream (curved arc downward from cup rim)
float waterStream(vec2 p, float x_off, float curve){
    float d = 1e9;
    for(int i=0; i<8; i++){
        float t = float(i) / 7.0;
        vec2 a = vec2(x_off + curve*t*t*0.5,      0.19 - t*0.18);
        vec2 b = vec2(x_off + curve*(t+0.14)*0.5*0.5, 0.19 - (t+0.14)*0.18);
        d = min(d, sdLine(p, a, b));
    }
    return smoothstep(0.005, 0.001, d);
}

// Cloud (horizontal bumpy shape)
float cloud(vec2 p, vec2 c, float scale){
    float d = sdBox(p - c, vec2(scale*0.6, scale*0.22));
    // Bumps
    for(int bi=-2; bi<=2; bi++){
        float bx = float(bi) * scale * 0.26;
        float by = scale * 0.22;
        d = min(d, sdCircle(p - c - vec2(bx, by), scale * 0.18));
    }
    return smoothstep(0.006, -0.002, d);
}

// Dove (simplified bird silhouette)
float dove(vec2 p, vec2 c){
    vec2 q = p - c;
    float body = smoothstep(0.004,-0.001, sdBox(q - vec2(0.0,0.0), vec2(0.030, 0.014)));
    float head  = smoothstep(0.004,-0.001, sdCircle(q - vec2(0.025, 0.010), 0.013));
    float tail  = smoothstep(0.004,-0.001, sdBox(q - vec2(-0.036, 0.0), vec2(0.014, 0.007)));
    // Wings (spread)
    float wing_l = smoothstep(0.004,-0.001, sdBox(q - vec2(-0.015, 0.020), vec2(0.025, 0.009)));
    float wing_r = smoothstep(0.004,-0.001, sdBox(q - vec2( 0.010, 0.018), vec2(0.020, 0.009)));
    return max(max(max(max(body,head),tail),wing_l),wing_r);
}

// Lotus blossom (simplified)
float lotus(vec2 p, vec2 c, float r){
    vec2 q = p - c;
    float center_petal = smoothstep(0.004,-0.001, sdCircle(q, r));
    float side_l = smoothstep(0.004,-0.001, sdCircle(q - vec2(-r*0.7, 0.0), r*0.7));
    float side_r = smoothstep(0.004,-0.001, sdCircle(q - vec2( r*0.7, 0.0), r*0.7));
    float back_l = smoothstep(0.004,-0.001, sdCircle(q - vec2(-r*0.5, r*0.4), r*0.55));
    float back_r = smoothstep(0.004,-0.001, sdCircle(q - vec2( r*0.5, r*0.4), r*0.55));
    return max(max(max(max(center_petal,side_l),side_r),back_l),back_r);
}

void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float sar = u_resolution.x / u_resolution.y;

    float ch = 0.88;
    float cw = ch / (1.73 * sar);
    vec2 cuv = (uv - 0.5 + vec2(cw,ch)*0.5) / vec2(cw,ch);
    float mask = step(0.0,cuv.x)*step(cuv.x,1.0)*step(0.0,cuv.y)*step(cuv.y,1.0);

    float bw   = u_border_weight*0.04+0.022;
    float edge = min(min(cuv.x,1.0-cuv.x),min(cuv.y,1.0-cuv.y));
    float in_outer  = step(edge,bw);
    float in_margin = step(edge,bw*1.9)*(1.0-in_outer);
    float in_inner  = (1.0-in_outer)*(1.0-in_margin);
    float title_bar   = step(cuv.y,0.115)*in_inner;
    float number_bar  = step(0.905,cuv.y)*in_inner;
    float image_field = in_inner*(1.0-title_bar)*(1.0-number_bar);

    vec3 CREAM = u_ground_color;
    vec3 GOLD  = mix(vec3(0.75,0.60,0.15),vec3(1.0,0.85,0.0),u_gold_intensity);
    vec3 DRED  = vec3(0.545,0.0,0.0);
    vec3 MBLUE = vec3(0.098,0.098,0.44);
    vec3 SKY   = u_sky_color;   // blue
    vec3 WHITE = vec3(0.96,0.96,0.94);
    vec3 WATER = mix(MBLUE, SKY, 0.5);

    float ify = (cuv.y - 0.115) / 0.79;

    // ── Sky: blue (water/emotional) with depth gradient ───────────────────────
    vec3 img = mix(CREAM*0.85, SKY, smoothstep(0.28, 0.72, ify));
    // Deeper blue at top
    img = mix(img, MBLUE*0.6, smoothstep(0.7, 1.0, ify)*0.5);

    // ── Water surface (lower third) ───────────────────────────────────────────
    {
        float water_y = 0.30;
        float water_mask = smoothstep(0.012, -0.004, ify - water_y);
        // Ripple texture
        float ripple_x = sin((cuv.x - 0.5) * 28.0) * 0.008;
        float ripple   = smoothHash(vec2(cuv.x * 8.0, (cuv.y + ripple_x) * 6.0 + u_time * 0.3)) * 0.15;
        img = mix(img, WATER*0.85 + vec3(ripple), water_mask);
        // Specular glints
        float glint = step(0.94, smoothHash(vec2(cuv.x*18.0+u_time*0.2, cuv.y*12.0)));
        img = mix(img, WHITE*0.9, water_mask * glint * 0.7);
    }

    // ── 8-point stars in sky ──────────────────────────────────────────────────
    {
        vec2 sg=cuv*vec2(8.0,10.0); vec2 sc=floor(sg); vec2 sf=fract(sg);
        float h=hash(sc);
        if(h > 1.0-u_symbol_density*0.30 && ify>0.45){
            float s=star8(sf-0.5, 0.22);
            img += GOLD*s*u_gold_intensity*0.65*smoothstep(0.45,0.58,ify);
        }
    }

    // ── Cloud (divine hand emerges from here) ─────────────────────────────────
    {
        float cl = cloud(cuv, vec2(0.5, 0.84), 0.12);
        img = mix(img, WHITE*0.94, cl);
        // Cloud outline
        float cl_edge = cl * smoothstep(0.13, 0.09, length(cuv - vec2(0.5, 0.84)));
        img = mix(img, vec3(0.35,0.38,0.45), cl_edge * u_outline_weight * 4.0);
    }

    // ── Disembodied hand (simple, emerging downward from cloud) ───────────────
    {
        // Palm (facing down, offering up the cup)
        vec2 hc = vec2(0.5, 0.76);
        float palm = smoothstep(0.004,-0.001, sdBox(cuv-hc, vec2(0.040,0.038)));
        // Fingers (5 — 4 finger rectangles + thumb)
        float fingers = 0.0;
        for(int fi=0; fi<4; fi++){
            float fx = (float(fi)-1.5)*0.020;
            fingers = max(fingers, smoothstep(0.003,-0.001, sdBox(cuv-hc-vec2(fx,-0.048), vec2(0.008,0.020))));
        }
        float thumb = smoothstep(0.003,-0.001, sdBox(cuv-hc-vec2(0.048,-0.010), vec2(0.012,0.016)));
        float hand = max(max(palm,fingers),thumb);
        img = mix(img, CREAM*0.88, hand);
        // Hand cuff (sleeve edge)
        float cuff = smoothstep(0.003,-0.001, sdBox(cuv-hc-vec2(0.0,0.042), vec2(0.048,0.008)));
        img = mix(img, WHITE*0.92, cuff);
        // Outlines
        float h_out = hand * smoothstep(0.043,0.036,sdBox(cuv-hc, vec2(0.040,0.038))+0.003);
        img = mix(img, vec3(0.04), h_out * u_outline_weight * 10.0);
    }

    // ── Ornate Chalice (centre of card) ──────────────────────────────────────
    {
        vec2 cup_c = vec2(0.5, 0.47);
        vec2 cp = cuv - cup_c;
        float ch_mask = chalice(cp);

        // Cup base colour: deep blue inside bowl
        img = mix(img, MBLUE*0.7+GOLD*0.15, ch_mask);

        // Gold rim and base decoration
        float rim_ring = smoothstep(0.003,-0.001, abs(sdBox(cp-vec2(0.0,0.185), vec2(0.094,0.012))));
        float foot_ring = smoothstep(0.003,-0.001, abs(sdBox(cp-vec2(0.0,-0.130), vec2(0.075,0.015))));
        img = mix(img, GOLD, (rim_ring+foot_ring) * u_gold_intensity * 0.9);

        // Cross on cup face (Rider-Waite Ace of Cups has a cross)
        float cross_h = smoothstep(0.003,0.0, sdBox(cp-vec2(0.0,0.10), vec2(0.032,0.006)));
        float cross_v = smoothstep(0.003,0.0, sdBox(cp-vec2(0.0,0.10), vec2(0.006,0.032)));
        img = mix(img, GOLD, (cross_h+cross_v)*ch_mask*u_gold_intensity*0.85);

        // Simple dark outline on exterior
        float bowl_edge = smoothstep(0.008, 0.002, abs(sdBox(cp-vec2(0.0,0.09), vec2(0.085,0.09))));
        img = mix(img, vec3(0.04), bowl_edge * u_outline_weight * 8.0);
    }

    // ── 5 water streams overflowing from cup ─────────────────────────────────
    {
        float s0 = waterStream(cuv - vec2(0.5, 0.47), -0.085,  0.04);
        float s1 = waterStream(cuv - vec2(0.5, 0.47), -0.042, -0.03);
        float s2 = waterStream(cuv - vec2(0.5, 0.47),  0.0,    0.0);
        float s3 = waterStream(cuv - vec2(0.5, 0.47),  0.042,  0.03);
        float s4 = waterStream(cuv - vec2(0.5, 0.47),  0.085, -0.04);
        float all_streams = max(max(max(max(s0, s1), s2), s3), s4);
        img = mix(img, SKY*0.8+WHITE*0.2, all_streams*0.8);
    }

    // ── Dove with wafer ───────────────────────────────────────────────────────
    {
        vec2 dove_c = vec2(0.5, 0.63);
        float dv = dove(cuv, dove_c);
        img = mix(img, WHITE*0.95, dv);
        // Wafer/disc in beak
        float wafer = smoothstep(0.004,-0.001, sdCircle(cuv-dove_c-vec2(0.038,0.010), 0.009));
        img = mix(img, GOLD, wafer*u_gold_intensity);
        // Dove outline
        img = mix(img, vec3(0.04), dv*smoothstep(0.033,0.025,sdBox(cuv-dove_c, vec2(0.030,0.014))+0.003)*u_outline_weight*9.0);
    }

    // ── Lotus blossoms on water ───────────────────────────────────────────────
    {
        float l1 = lotus(cuv, vec2(0.28, 0.27), 0.028);
        float l2 = lotus(cuv, vec2(0.72, 0.26), 0.028);
        float l3 = lotus(cuv, vec2(0.50, 0.24), 0.022);
        img = mix(img, WHITE*0.92, (l1+l2+l3));
        img = mix(img, GOLD*0.7, (l1+l2+l3)*u_gold_intensity*0.4);
    }

    // ── Yod drops (blessings raining) ────────────────────────────────────────
    {
        float cnt = u_symbol_density * 20.0 + 5.0;
        for(int yi = 0; yi < 25; yi++){
            if(float(yi) >= cnt) break;
            float fyi = float(yi);
            float h = hash1(fyi * 6.7);
            float h2 = hash1(fyi * 11.3 + 2.0);
            vec2 yp = cuv - vec2(0.12 + h*0.76, 0.30 + h2*0.50);
            float drop = smoothstep(0.009,0.0, sdCircle(yp, 0.008))
                       + smoothstep(0.005,-0.001, sdBox(yp-vec2(0.0,-0.010), vec2(0.004,0.010)));
            img = mix(img, GOLD, min(drop,1.0)*u_gold_intensity*0.7);
        }
    }

    // ── Border ────────────────────────────────────────────────────────────────
    float shimmer = sin(cuv.x*38.0+u_time*0.5)*sin(cuv.y*38.0+u_time*0.5)*0.5+0.5;
    vec3 border_col = mix(GOLD*0.65, GOLD, shimmer*u_gold_intensity);
    float iline = smoothstep(0.0028,0.0,abs(edge-bw*1.9));
    float cdeco = 0.0;
    vec2 corn[4];
    corn[0]=vec2(bw*0.85,bw*0.85); corn[1]=vec2(1.0-bw*0.85,bw*0.85);
    corn[2]=vec2(bw*0.85,1.0-bw*0.85); corn[3]=vec2(1.0-bw*0.85,1.0-bw*0.85);
    for(int ci=0;ci<4;ci++) cdeco=max(cdeco,cornerDeco(cuv-corn[ci],bw*0.88));

    vec3 title_dark = MBLUE*0.45+DRED*0.25;
    float ttext = smoothstep(0.0025,0.0,abs(cuv.y-0.057)-0.022)*smoothstep(0.004,0.0,abs(cuv.x-0.5)-0.28);
    float ntext = smoothstep(0.0025,0.0,abs(cuv.y-0.952)-0.018)*smoothstep(0.004,0.0,abs(cuv.x-0.5)-0.065);

    vec3 col = vec3(0.07);
    col = mix(col, CREAM,       mask);
    col = mix(col, img,         mask * image_field);
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

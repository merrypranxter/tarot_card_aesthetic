// The Tower — Major Arcana XVI — Rider-Waite Revival
// Card: XVI — THE TOWER
// Aesthetic: RIDER_WAITE_REVIVAL
// Palette: Cream, Gold, Storm Grey/Blue, Deep Red, Near-Black
//
// Sky grammar: STORM GREY — challenge, crisis, sudden disruption.
//   The sky is the colour of forced clarity. Lightning does not ask permission.
//   Grey = the dissolution of false structures. What falls was hollow.
//
// Card imagery (Pamela Coleman Smith, 1909):
//   - Tower struck by lightning: tall, narrow, battlements at top
//   - Lightning bolt (bright gold/white) striking the crown
//   - Crown blown off (falling)
//   - Two figures falling headfirst from the tower windows
//   - 22 flames / Yod letters falling (22 = Hebrew letters = paths of the Tree)
//   - Dark storm sky behind
//   - Rocky cliff below
//
// Symbolic vocabulary:
//   Tower = false structure, ego-fortress, the Tower of Babel
//   Lightning = divine intervention, the flash of truth, Kundalini rising
//   Crown = false kingship, hubris, the thing that cannot stay
//   Falling figures = the inevitable descent after inflation
//   22 Yods = the 22 paths of the Tree of Life breaking loose, seeds of new growth
//   Fire/flames = purification, the burning off of what doesn't serve

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
float sdTriangle(vec2 p, float r){
    const float k=1.7320508;
    p.x=abs(p.x)-r; p.y=p.y+r/k;
    if(p.x+k*p.y>0.0) p=vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x-=clamp(p.x,-2.0*r,0.0);
    return -length(p)*sign(p.y);
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

// Yod — Hebrew letter (simplified: comma-like drop)
float yod(vec2 p, float sz){
    float body = smoothstep(0.005,-0.001,sdCircle(p, sz));
    float tail = smoothstep(0.004,-0.001,sdLine(p, vec2(0.0), vec2(sz*0.6,-sz*1.2)) - sz*0.3);
    return max(body, tail);
}

// Lightning bolt (zigzag)
float lightningBolt(vec2 p){
    // 3-segment zigzag bolt
    float d = 1e9;
    // Segment 1: top-right to mid-left
    d = min(d, sdLine(p, vec2(0.06, 0.38), vec2(-0.04, 0.18)));
    // Segment 2: mid-left to centre
    d = min(d, sdLine(p, vec2(-0.04, 0.18), vec2(0.03, 0.08)));
    // Segment 3: centre to bottom-right
    d = min(d, sdLine(p, vec2(0.03, 0.08), vec2(-0.06, -0.08)));
    float width = 0.010;
    return smoothstep(width, width*0.3, d);
}

// Tower silhouette (narrow rectangle with battlements)
float tower(vec2 p){
    // Main shaft
    float shaft = smoothstep(0.004,-0.002, sdBox(p - vec2(0.0, 0.0), vec2(0.065, 0.28)));
    // Battlements (3 merlons on top)
    float batt = 0.0;
    for(int bi=-1; bi<=1; bi++){
        float bx = float(bi) * 0.038;
        batt = max(batt, smoothstep(0.004,-0.001, sdBox(p - vec2(bx, 0.29), vec2(0.016, 0.016))));
    }
    // Door at base
    float door = smoothstep(0.003,-0.001, sdBox(p - vec2(0.0, -0.20), vec2(0.020, 0.038)));
    // Windows (2)
    float win1 = smoothstep(0.003,-0.001, sdBox(p - vec2(-0.025, 0.05), vec2(0.014, 0.018)));
    float win2 = smoothstep(0.003,-0.001, sdBox(p - vec2( 0.025, 0.08), vec2(0.014, 0.018)));
    // Combine: shaft + battlements, minus door and windows
    float tow = max(shaft, batt);
    tow = tow * (1.0 - door) * (1.0 - win1) * (1.0 - win2);
    return tow;
}

// Falling figure (simplified tumbling person)
float fallingFigure(vec2 p, bool flip){
    vec2 q = flip ? vec2(-p.x, p.y) : p;
    // Body (diagonal)
    float body = smoothstep(0.004,-0.001,sdBox(q - vec2(0.0,-0.01), vec2(0.018,0.038)));
    // Head
    float head = smoothstep(0.004,-0.001,sdCircle(q - vec2(0.008, 0.04), 0.016));
    // Arms (spread)
    float arm1 = smoothstep(0.003,-0.001,sdBox(q - vec2(-0.028,0.01), vec2(0.022,0.008)));
    float arm2 = smoothstep(0.003,-0.001,sdBox(q - vec2( 0.025,0.01), vec2(0.018,0.008)));
    // Legs (spread)
    float leg1 = smoothstep(0.003,-0.001,sdBox(q - vec2(-0.018,-0.045), vec2(0.008,0.022)));
    float leg2 = smoothstep(0.003,-0.001,sdBox(q - vec2( 0.018,-0.050), vec2(0.008,0.022)));
    return max(max(max(body,head),max(arm1,arm2)),max(leg1,leg2));
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
    vec3 STORM = u_sky_color; // grey
    vec3 GREY  = vec3(0.38,0.38,0.42);
    vec3 AMBER = vec3(1.0,0.55,0.0);

    float ify = (cuv.y-0.115)/0.79;

    // ── Storm sky (dark grey, churning) ──────────────────────────────────────
    float cloud_noise = smoothHash(vec2(cuv.x*3.0+u_time*0.04, cuv.y*2.5))*0.18;
    vec3 img = mix(STORM*0.75, STORM, smoothstep(0.3, 0.9, ify) + cloud_noise);
    // Darker at top
    img = mix(img, STORM*0.55, smoothstep(0.65,1.0,ify));

    // Cloud texture
    {
        float cn = smoothHash(cuv*vec2(5.0,3.0)+vec2(u_time*0.02,0.0));
        img = mix(img, GREY*0.8, cn*0.15*(ify>0.35?1.0:0.0));
    }

    // ── Rocky ground (bottom) ─────────────────────────────────────────────────
    {
        float rock_y = 0.24 - smoothHash(vec2(cuv.x*4.0,0.0))*0.06;
        float rocks = smoothstep(0.006,-0.004,ify - rock_y);
        img = mix(img, GREY*0.55+CREAM*0.15, rocks*0.9);
    }

    // ── Tower (centred, tall) ─────────────────────────────────────────────────
    {
        vec2 tow_c = vec2(0.50, 0.48);
        vec2 tp    = cuv - tow_c;

        float tow = tower(tp);
        // Stone texture on tower
        float stone_h = smoothHash(vec2(floor(cuv.x*24.0), floor((cuv.y-0.12)*30.0))) * 0.12;
        img = mix(img, CREAM*0.6 + GREY*0.25 + stone_h*vec3(0.1,0.08,0.05), tow);

        // Tower outline
        float shaft_d = sdBox(tp - vec2(0.0,0.0), vec2(0.065,0.28));
        float tow_out = tow * smoothstep(0.065,0.058,shaft_d + 0.004);
        img = mix(img, vec3(0.04), tow_out * u_outline_weight * 12.0);

        // Fire at top (orange/red glow)
        float fire_y = 0.30;
        float fire_d = length(tp - vec2(0.0, fire_y));
        float fire_glow = smoothstep(0.12, 0.0, fire_d) * 0.55 * u_gold_intensity;
        img = mix(img, AMBER*1.1, fire_glow*tow);
        // Flame tongues
        for(int fi=0; fi<4; fi++){
            float fx = (float(fi)-1.5)*0.025;
            float fh = 0.04 + hash1(float(fi)*3.7)*0.025 + sin(u_time*3.0+float(fi))*0.008;
            float flame = smoothstep(0.012,-0.001,sdBox(tp - vec2(fx, fire_y+fh*0.5), vec2(0.010, fh)));
            img = mix(img, mix(AMBER, DRED*1.2, float(fi)/3.0)*1.1, flame*u_gold_intensity);
        }

        // Crown falling off (diamond shape, tilted, above battlements)
        vec2 crown_c = vec2(0.52, 0.81);
        float angle  = sin(u_time*0.4)*0.3 + 0.4;
        vec2 rc      = vec2(cos(angle)*(cuv.x-crown_c.x)-sin(angle)*(cuv.y-crown_c.y),
                            sin(angle)*(cuv.x-crown_c.x)+cos(angle)*(cuv.y-crown_c.y));
        float crown = 0.0;
        for(int ci=-1; ci<=1; ci++){
            float cx = float(ci)*0.018;
            crown = max(crown, smoothstep(0.005,-0.001,sdBox(rc - vec2(cx, 0.0), vec2(0.010,0.020))));
        }
        float crown_base = smoothstep(0.003,-0.001,sdBox(rc, vec2(0.040,0.007)));
        crown = max(crown, crown_base);
        img = mix(img, GOLD*0.9, crown*u_gold_intensity);
    }

    // ── Lightning bolt (striking the crown) ──────────────────────────────────
    {
        vec2 lb_c = vec2(0.50, 0.65);
        float lb = lightningBolt(cuv - lb_c);
        // White core
        img = mix(img, vec3(0.98, 0.96, 0.8), lb * 0.95);
        // Gold outer glow
        float lb_glow = lightningBolt((cuv-lb_c)*0.85) * (1.0-lb);
        img = mix(img, GOLD, lb_glow * u_gold_intensity * 0.7);
        // Flash pulse
        float flash = exp(-length(cuv - vec2(0.50, 0.70)) * 7.0) * 0.15 * u_gold_intensity;
        img = mix(img, vec3(1.0, 0.9, 0.6), flash);
    }

    // ── Falling figures (left and right of tower) ─────────────────────────────
    {
        // Left figure
        vec2 p1 = cuv - vec2(0.34, 0.52);
        float fig1 = fallingFigure(p1, false);
        img = mix(img, DRED*0.85, fig1);
        img = mix(img, vec3(0.04), fig1*smoothstep(0.022,0.016,sdBox(p1, vec2(0.018,0.038))+0.003)*u_outline_weight*10.0);

        // Right figure
        vec2 p2 = cuv - vec2(0.66, 0.44);
        float fig2 = fallingFigure(p2, true);
        img = mix(img, CREAM*0.85, fig2);
        img = mix(img, vec3(0.04), fig2*smoothstep(0.022,0.016,sdBox(p2, vec2(0.018,0.038))+0.003)*u_outline_weight*10.0);
    }

    // ── 22 Yod letters / falling flames (scattered) ──────────────────────────
    {
        float cnt = u_symbol_density * 18.0 + 4.0;
        for(float yi=0.0; yi<22.0; yi++){
            if(yi >= cnt) break;
            float h = hash1(yi*7.1);
            float h2 = hash1(yi*13.3+1.5);
            vec2 yp = cuv - vec2(0.10 + h*0.80, 0.25 + h2*0.62);
            float y_glyph = yod(yp, 0.010);
            img = mix(img, mix(GOLD, AMBER, h), y_glyph * u_gold_intensity * 0.8);
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
    float ttext = smoothstep(0.0025,0.0,abs(cuv.y-0.057)-0.022)*smoothstep(0.004,0.0,abs(cuv.x-0.5)-0.27);
    float ntext = smoothstep(0.0025,0.0,abs(cuv.y-0.952)-0.018)*smoothstep(0.004,0.0,abs(cuv.x-0.5)-0.055);

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

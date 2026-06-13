# tarot_card_aesthetic

> the card knows what it is. you are the variable.

Tarot visual grammar — from Pamela Coleman Smith's ink washes for Rider-Waite (1909) through the explosion of contemporary indie decks. The vertical rectangle. The border system. The symbolic vocabulary. The specific relationship between figure, ground, title, and number that makes a card a card.

## What This Is

Self-contained GLSL fragment shaders capturing the visual language of tarot across five aesthetic regimes. Three specific card studies. One unified viewer. Every shader is a complete card format system: border hierarchy, title placement, number placement, figure or pip positioning.

## Stack

`Three.js` + `WebGL2` + `GLSL` + `Vite`

---

## Quick Start

```bash
npm install
npm run dev
```

Open `http://localhost:5173`. Use the sidebar to switch between shaders and adjust uniforms live.

---

## Visual DNA

### Card Format

- **Aspect ratio**: 2.75" × 4.75" = **1 : 1.73** portrait
- **Border system**: outer decorative border → inner margin → image field → title bar
- **Title**: bottom center, ornate typeface, all caps — the card names itself
- **Number**: Roman numeral top center (Major Arcana) or pip count (Minor)
- **Color ground**: warm cream/ivory (`#FFF8E7`) or black for dark decks — the paper is a choice

### Sky Grammar (Rider-Waite)

| Sky color | Symbolic meaning |
|-----------|-----------------|
| Yellow | Day consciousness, hope, solar will. The Fool walks toward it. The Sun card is it. |
| Blue | Water, emotion, the unconscious. Cups cards, The Moon. |
| Grey/storm | Challenge, crisis, transformation. The Tower, Five of Swords. |
| Black/night | The void, the deep unknown. The Moon's second face. |
| Dawn orange | Transition, new beginning. Judgement. |

### Symbol Vocabulary

| Suit | Element | Domain |
|------|---------|--------|
| Cups | Water | Emotion, relationship, intuition |
| Wands | Fire | Will, creativity, passion |
| Swords | Air | Mind, conflict, clarity |
| Pentacles | Earth | Material, body, craft |

---

## Shader Inventory

### Aesthetic Regimes

| File | Regime | Palette | Ground |
|------|--------|---------|--------|
| `rider_waite_revival.frag.glsl` | RIDER_WAITE_REVIVAL | Cream, gold, deep red, midnight blue, green | Cream `#FFF8E7` |
| `marseille_flat.frag.glsl` | MARSEILLE_FLAT | Red, yellow, blue, wheat | Wheat `#F5DEB3` |
| `thoth_aethyr.frag.glsl` | THOTH_AETHYR | Near-black, gold, dark magenta, dark blue | Black `#1C1C1C` |
| `indie_minimal.frag.glsl` | INDIE_MINIMAL | White, near-black, sage accent | White `#FAFAFA` |
| `dark_oracle.frag.glsl` | DARK_ORACLE | Black, aged gold, dark red | Black `#0D0D0D` |

### Card Studies

| File | Card | Number | Notes |
|------|------|--------|-------|
| `major_arcana_fool.frag.glsl` | The Fool | 0 | Yellow sky, cliff, sun, dog, flower — pure Rider-Waite |
| `major_arcana_tower.frag.glsl` | The Tower | XVI | Storm sky, lightning, crown, falling figures |
| `minor_arcana_cups.frag.glsl` | Ace of Cups | I (Cups) | Blue sky, ornate chalice, dove, overflowing water |

---

## Shader Uniforms

```glsl
uniform float u_border_weight;   // ornamental border thickness, 0..1
uniform float u_gold_intensity;  // gold accent saturation, 0..1
uniform float u_outline_weight;  // figure outline thickness, 0..1
uniform vec3  u_sky_color;       // symbolic sky color (RGB)
uniform vec3  u_ground_color;    // card ground/paper color (RGB)
uniform float u_symbol_density;  // secondary symbol scatter, 0..1
uniform int   u_arcana_number;   // 0–21, influences composition
```

### Default Values Per Regime

| Regime | sky_color | ground_color | gold_intensity |
|--------|-----------|--------------|----------------|
| RIDER_WAITE_REVIVAL | `1.0, 0.85, 0.0` (yellow) | `1.0, 0.97, 0.91` (cream) | 0.9 |
| MARSEILLE_FLAT | `1.0, 0.85, 0.0` (yellow) | `0.96, 0.87, 0.7` (wheat) | 0.7 |
| THOTH_AETHYR | `0.0, 0.0, 0.55` (dark blue) | `0.11, 0.11, 0.11` (near-black) | 1.0 |
| INDIE_MINIMAL | `0.6, 0.8, 0.7` (sage) | `0.98, 0.98, 0.98` (white) | 0.3 |
| DARK_ORACLE | `0.55, 0.11, 0.11` (dark red) | `0.05, 0.05, 0.05` (black) | 0.8 |

---

## Core Shader Math

```
Card aspect:   1 : 1.73  (portrait)
Card zones:    outer_border (4%) / inner_margin (7%) / image_field (77%) / title_bar (12% bottom) / number_bar (9% top)
Border SDF:    distance from nearest card edge, thresholded at bw and bw×1.8
Gold shimmer:  sin(cuv.x × freq + t) × sin(cuv.y × freq + t) — thin-film iridescence
Star flare:    8-point cross: min(max(|p.x|,|p.y|), (|p.x|+|p.y|)×0.707)
Pip hash:      fract(sin(dot(p, vec2(127.1, 311.7))) × 43758.5)
Sky gradient:  vertical mix(ground_color, sky_color, smoothstep(0.35, 0.65, cuv.y))
```

---

## Ecosystem

Part of the [merrypranxter](https://github.com/merrypranxter) generative art pipeline.

Compatible context modules: `sacred_geometry`, `symbolist_style`, `tibetan_thangka_style`, `gematria_resonance`, `i_ching_fields`

> Every border is a threshold. Every symbol is a door. The format is the constraint, and the constraint is what makes it work.

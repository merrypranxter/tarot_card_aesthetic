# tarot_card_aesthetic

the card knows what it is. you are the variable.

Tarot visual grammar — from Pamela Coleman Smith's ink washes for Rider-Waite (1909) through the explosion of contemporary indie decks. The vertical rectangle. The border system. The symbolic vocabulary. The specific relationship between figure, ground, title, and number that makes a card a card.

## What This Is

Visual language and compositional grammar for tarot-styled generative art — the card format as creative constraint, the symbolic visual vocabulary as generative grammar.

## Visual DNA

**Card format:**
- Portrait rectangle: 2.75" × 4.75" ratio (roughly 1:1.73)
- Border system: outer decorative border + inner margin + image field + title bar
- Title position: bottom center, ornate typeface, all caps
- Number: Roman numeral top center (Major Arcana) or pip count (Minor)
- Color ground: warm cream/ivory (`#FFF8E7`) or black for dark decks

**Rider-Waite signatures (1909 style):**
- Flat wash color: no strong lighting, colors as symbolic not naturalistic
- Heavy outline: 2–3px black outline on all figures
- Gold accents: sun, stars, halos, wheat — `#FFD700`, `#DAA520`
- Sky grammar: yellow sky = day consciousness, blue = water/unconscious, grey = storm/challenge
- Figure types: robed, crowned, winged, clothed in colors that carry meaning
- Symbol vocabulary: cups (water/emotion), wands (fire/will), swords (air/mind), pentacles (earth/material)

**Contemporary indie deck signatures:**
- Minimal line art: 1px stroke, lots of negative space
- Single accent color on white: monochrome + one vivid hue
- Geometric symbolism: circles, triangles, stars as primary symbols vs. narrative figures
- Nature-forward: plants, animals, celestial bodies as card images
- Dark decks: gold on black, silver on charcoal

**Color palettes:**
- `RIDER_WAITE`: `#FFF8E7` (cream), `#FFD700` (gold), `#8B0000` (deep red), `#191970` (midnight blue), `#228B22` (green)
- `MARSEILLE_FLAT`: `#FF4500` (red), `#FFD700` (yellow), `#000080` (blue), `#F5DEB3` (wheat)
- `THOTH_JEWEL`: `#1C1C1C` (black), `#DAA520` (gold), `#8B008B` (dark magenta), `#00008B` (dark blue)
- `INDIE_MONO`: `#FAFAFA` (white), `#1A1A1A` (near black), one accent color
- `DARK_DECK`: `#0D0D0D` (black), `#C0A870` (aged gold), `#8B1C1C` (dark red)

## Aesthetic Regimes

### `RIDER_WAITE_REVIVAL` — Classic 1909 illustrated style
Cream ground. Heavy outline figures. Gold accents. Symbolic sky colors. Dense symbol vocabulary per card.

### `MARSEILLE_FLAT` — Pre-Rider geometric pips
Flat geometric pip arrangement. No narrative scenes on numbered cards. Decorative rather than illustrative.

### `THOTH_AETHYR` — Crowley/Harris esoteric abstraction
Geometric and abstract symbolism. Jewel colors on near-black. Astrological and Kabbalistic diagram elements.

### `INDIE_MINIMAL` — Contemporary single-line
White ground. Hairline illustration. One accent color. Negative space as meaning. Plants and animals.

### `DARK_ORACLE` — Black ground, gold mark
Black ground. Gold and aged-red mark-making. High contrast. Feels archaic and urgent simultaneously.

## Shader Parameters

```glsl
uniform float u_border_weight;      // ornamental border thickness
uniform float u_gold_intensity;     // 0.0–1.0, gold accent saturation
uniform float u_outline_weight;     // figure outline thickness px
uniform vec3  u_sky_color;          // symbolic sky color
uniform vec3  u_ground_color;       // card ground/paper color
uniform float u_symbol_density;     // 0.0–1.0, secondary symbol scatter
uniform int   u_arcana_number;      // 0–21, influences composition
```

## Ecosystem

Part of the [merrypranxter](https://github.com/merrypranxter) generative art pipeline.
RepoScripter2 context source. ShaderForge style module.

Use with: `sacred_geometry`, `symbolist_style`, `tibetan_thangka_style`, `gematria_resonance`, `i_ching_fields`

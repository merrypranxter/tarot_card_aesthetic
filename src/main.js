import * as THREE from 'three';

// ── Shader imports (Vite raw) ────────────────────────────────────────────────
import riderWaite  from './shaders/rider_waite_revival.frag.glsl?raw';
import marseille   from './shaders/marseille_flat.frag.glsl?raw';
import thoth       from './shaders/thoth_aethyr.frag.glsl?raw';
import indieMin    from './shaders/indie_minimal.frag.glsl?raw';
import darkOracle  from './shaders/dark_oracle.frag.glsl?raw';
import theFool     from './shaders/major_arcana_fool.frag.glsl?raw';
import theTower    from './shaders/major_arcana_tower.frag.glsl?raw';
import aceCups     from './shaders/minor_arcana_cups.frag.glsl?raw';

// ── Shader catalogue ─────────────────────────────────────────────────────────
const SHADERS = [
  {
    label: 'Rider-Waite Revival',
    glsl: riderWaite,
    desc: 'Classic 1909 illustrated style. Cream ground, heavy gold border, symbolic yellow sky, star flares, crowned figure in red robes.',
    defaults: { border_weight: 0.5, gold_intensity: 0.9, outline_weight: 0.6, sky_r: 1.0, sky_g: 0.85, sky_b: 0.0, gnd_r: 1.0, gnd_g: 0.97, gnd_b: 0.91, symbol_density: 0.7, arcana_number: 0 }
  },
  {
    label: 'Marseille Flat',
    glsl: marseille,
    desc: 'Pre-Rider geometric pip arrangement. Flat red/blue/yellow fills on wheat. Decorative, not illustrative. No narrative scenes.',
    defaults: { border_weight: 0.5, gold_intensity: 0.7, outline_weight: 0.8, sky_r: 1.0, sky_g: 0.85, sky_b: 0.0, gnd_r: 0.96, gnd_g: 0.87, gnd_b: 0.7, symbol_density: 0.6, arcana_number: 5 }
  },
  {
    label: 'Thoth Aethyr',
    glsl: thoth,
    desc: 'Crowley/Harris esoteric abstraction. Jewel colours on near-black. Astrological circles, Kabbalistic geometry, radiant gold.',
    defaults: { border_weight: 0.5, gold_intensity: 1.0, outline_weight: 0.5, sky_r: 0.0, sky_g: 0.0, sky_b: 0.55, gnd_r: 0.11, gnd_g: 0.11, gnd_b: 0.11, symbol_density: 0.8, arcana_number: 11 }
  },
  {
    label: 'Indie Minimal',
    glsl: indieMin,
    desc: 'Contemporary single-line. White ground, hairline botanical illustration, one sage accent. Negative space as meaning.',
    defaults: { border_weight: 0.3, gold_intensity: 0.3, outline_weight: 0.9, sky_r: 0.6, sky_g: 0.8, sky_b: 0.7, gnd_r: 0.98, gnd_g: 0.98, gnd_b: 0.98, symbol_density: 0.5, arcana_number: 2 }
  },
  {
    label: 'Dark Oracle',
    glsl: darkOracle,
    desc: 'Black ground, aged gold and dark red mark-making. High contrast. Feels archaic and urgent simultaneously.',
    defaults: { border_weight: 0.6, gold_intensity: 0.8, outline_weight: 0.7, sky_r: 0.55, sky_g: 0.11, sky_b: 0.11, gnd_r: 0.05, gnd_g: 0.05, gnd_b: 0.05, symbol_density: 0.6, arcana_number: 15 }
  },
  {
    label: 'The Fool — 0',
    glsl: theFool,
    desc: 'Major Arcana 0. Yellow sky of pure day consciousness. Cliff edge. White dog. Flower. The step beyond reason.',
    defaults: { border_weight: 0.5, gold_intensity: 0.95, outline_weight: 0.65, sky_r: 1.0, sky_g: 0.88, sky_b: 0.05, gnd_r: 1.0, gnd_g: 0.97, gnd_b: 0.91, symbol_density: 0.5, arcana_number: 0 }
  },
  {
    label: 'The Tower — XVI',
    glsl: theTower,
    desc: 'Major Arcana 16. Storm sky, grey with lightning. The crown falls. Two figures fall. Sudden revelation through destruction.',
    defaults: { border_weight: 0.5, gold_intensity: 0.7, outline_weight: 0.7, sky_r: 0.35, sky_g: 0.35, sky_b: 0.4, gnd_r: 1.0, gnd_g: 0.97, gnd_b: 0.91, symbol_density: 0.6, arcana_number: 16 }
  },
  {
    label: 'Ace of Cups',
    glsl: aceCups,
    desc: 'Minor Arcana, Cups suit, Ace. Blue water sky. Ornate chalice overflowing. Dove descending with wafer. Water as pure emotion.',
    defaults: { border_weight: 0.5, gold_intensity: 0.9, outline_weight: 0.6, sky_r: 0.1, sky_g: 0.35, sky_b: 0.85, gnd_r: 1.0, gnd_g: 0.97, gnd_b: 0.91, symbol_density: 0.6, arcana_number: 1 }
  }
];

// ── Three.js setup ───────────────────────────────────────────────────────────
const canvas = document.getElementById('c');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

const scene = new THREE.Scene();
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
const geometry = new THREE.PlaneGeometry(2, 2);

const VERT = `void main(){ gl_Position = vec4(position, 1.0); }`;

function makeUniforms(s) {
  return {
    u_time:           { value: 0.0 },
    u_resolution:     { value: new THREE.Vector2() },
    u_border_weight:  { value: s.defaults.border_weight },
    u_gold_intensity: { value: s.defaults.gold_intensity },
    u_outline_weight: { value: s.defaults.outline_weight },
    u_sky_color:      { value: new THREE.Vector3(s.defaults.sky_r,  s.defaults.sky_g,  s.defaults.sky_b)  },
    u_ground_color:   { value: new THREE.Vector3(s.defaults.gnd_r,  s.defaults.gnd_g,  s.defaults.gnd_b)  },
    u_symbol_density: { value: s.defaults.symbol_density },
    u_arcana_number:  { value: s.defaults.arcana_number }
  };
}

let material = new THREE.ShaderMaterial({
  vertexShader: VERT,
  fragmentShader: SHADERS[0].glsl,
  uniforms: makeUniforms(SHADERS[0])
});
const mesh = new THREE.Mesh(geometry, material);
scene.add(mesh);

function resize() {
  const w = canvas.parentElement.clientWidth;
  const h = canvas.parentElement.clientHeight;
  renderer.setSize(w, h, false);
  material.uniforms.u_resolution.value.set(w * renderer.getPixelRatio(), h * renderer.getPixelRatio());
}
resize();
window.addEventListener('resize', resize);

// ── UI wiring ────────────────────────────────────────────────────────────────
const select = document.getElementById('shader-select');
SHADERS.forEach((s, i) => {
  const opt = document.createElement('option');
  opt.value = i;
  opt.textContent = s.label;
  select.appendChild(opt);
});

function applyDefaults(idx) {
  const s = SHADERS[idx];
  const d = s.defaults;
  document.getElementById('border_weight').value  = d.border_weight;
  document.getElementById('gold_intensity').value = d.gold_intensity;
  document.getElementById('outline_weight').value = d.outline_weight;
  document.getElementById('sky_r').value   = d.sky_r;
  document.getElementById('sky_g').value   = d.sky_g;
  document.getElementById('sky_b').value   = d.sky_b;
  document.getElementById('gnd_r').value   = d.gnd_r;
  document.getElementById('gnd_g').value   = d.gnd_g;
  document.getElementById('gnd_b').value   = d.gnd_b;
  document.getElementById('symbol_density').value = d.symbol_density;
  document.getElementById('arcana_number').value  = d.arcana_number;
  // Update displayed values
  document.getElementById('bw-val').textContent  = d.border_weight.toFixed(2);
  document.getElementById('gi-val').textContent  = d.gold_intensity.toFixed(2);
  document.getElementById('ow-val').textContent  = d.outline_weight.toFixed(2);
  document.getElementById('sky-r-val').textContent = d.sky_r.toFixed(2);
  document.getElementById('sky-g-val').textContent = d.sky_g.toFixed(2);
  document.getElementById('sky-b-val').textContent = d.sky_b.toFixed(2);
  document.getElementById('gnd-r-val').textContent = d.gnd_r.toFixed(2);
  document.getElementById('gnd-g-val').textContent = d.gnd_g.toFixed(2);
  document.getElementById('gnd-b-val').textContent = d.gnd_b.toFixed(2);
  document.getElementById('sd-val').textContent  = d.symbol_density.toFixed(2);
  document.getElementById('an-val').textContent  = d.arcana_number;
  updateSwatches();
}

function updateSwatches() {
  const r = parseFloat(document.getElementById('sky_r').value);
  const g = parseFloat(document.getElementById('sky_g').value);
  const b = parseFloat(document.getElementById('sky_b').value);
  document.getElementById('sky-swatch').style.background =
    `rgb(${Math.round(r*255)},${Math.round(g*255)},${Math.round(b*255)})`;
  const gr = parseFloat(document.getElementById('gnd_r').value);
  const gg = parseFloat(document.getElementById('gnd_g').value);
  const gb = parseFloat(document.getElementById('gnd_b').value);
  document.getElementById('gnd-swatch').style.background =
    `rgb(${Math.round(gr*255)},${Math.round(gg*255)},${Math.round(gb*255)})`;
}

function switchShader(idx) {
  const s = SHADERS[idx];
  scene.remove(mesh);
  material.dispose();
  material = new THREE.ShaderMaterial({
    vertexShader: VERT,
    fragmentShader: s.glsl,
    uniforms: makeUniforms(s)
  });
  mesh.material = material;
  scene.add(mesh);
  applyDefaults(idx);
  document.getElementById('shader-desc').textContent = s.desc;
  resize();
}

select.addEventListener('change', e => switchShader(parseInt(e.target.value)));

// Range inputs → uniforms
function wireRange(id, labelId, uniformKey, isInt) {
  const el = document.getElementById(id);
  const lbl = document.getElementById(labelId);
  el.addEventListener('input', () => {
    const v = isInt ? parseInt(el.value) : parseFloat(el.value);
    if (lbl) lbl.textContent = isInt ? v : v.toFixed(2);
    material.uniforms[uniformKey].value = v;
    if (id.startsWith('sky_') || id.startsWith('gnd_')) updateSwatches();
  });
}
wireRange('border_weight',  'bw-val',    'u_border_weight');
wireRange('gold_intensity', 'gi-val',    'u_gold_intensity');
wireRange('outline_weight', 'ow-val',    'u_outline_weight');
wireRange('symbol_density', 'sd-val',    'u_symbol_density');
wireRange('arcana_number',  'an-val',    'u_arcana_number', true);

// Sky/ground color channels
['r','g','b'].forEach(ch => {
  document.getElementById(`sky_${ch}`).addEventListener('input', () => {
    material.uniforms.u_sky_color.value.set(
      parseFloat(document.getElementById('sky_r').value),
      parseFloat(document.getElementById('sky_g').value),
      parseFloat(document.getElementById('sky_b').value)
    );
    const v = parseFloat(document.getElementById(`sky_${ch}`).value);
    document.getElementById(`sky-${ch}-val`).textContent = v.toFixed(2);
    updateSwatches();
  });
  document.getElementById(`gnd_${ch}`).addEventListener('input', () => {
    material.uniforms.u_ground_color.value.set(
      parseFloat(document.getElementById('gnd_r').value),
      parseFloat(document.getElementById('gnd_g').value),
      parseFloat(document.getElementById('gnd_b').value)
    );
    const v = parseFloat(document.getElementById(`gnd_${ch}`).value);
    document.getElementById(`gnd-${ch}-val`).textContent = v.toFixed(2);
    updateSwatches();
  });
});

// Sky preset buttons
document.querySelectorAll('.sky-preset').forEach(btn => {
  btn.addEventListener('click', () => {
    const r = parseFloat(btn.dataset.r);
    const g = parseFloat(btn.dataset.g);
    const b = parseFloat(btn.dataset.b);
    document.getElementById('sky_r').value = r;
    document.getElementById('sky_g').value = g;
    document.getElementById('sky_b').value = b;
    document.getElementById('sky-r-val').textContent = r.toFixed(2);
    document.getElementById('sky-g-val').textContent = g.toFixed(2);
    document.getElementById('sky-b-val').textContent = b.toFixed(2);
    material.uniforms.u_sky_color.value.set(r, g, b);
    updateSwatches();
  });
});

// ── Render loop ──────────────────────────────────────────────────────────────
let lastTime = performance.now();
let frameCount = 0;
const fpsEl = document.getElementById('fps');

function animate(now) {
  material.uniforms.u_time.value = now * 0.001;
  renderer.render(scene, camera);

  frameCount++;
  const dt = now - lastTime;
  if (dt >= 1000) {
    fpsEl.textContent = `${Math.round(frameCount * 1000 / dt)} fps`;
    frameCount = 0;
    lastTime = now;
  }
  requestAnimationFrame(animate);
}

// Init
switchShader(0);
requestAnimationFrame(animate);

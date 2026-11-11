// Hanko — touches vivantes du Stream Deck pour OpenDeck.
//
// Trois actions, dessinées avec le kit Hanko (assets/) :
//   com.moozydev.hanko.vol    volume d'un canal dans un mix OpenXLR (ou d'un mix
//                             entier), jauge à 10 segments + valeur en direct,
//                             calque « COUPÉ » quand ce son est coupé ;
//   com.moozydev.hanko.mute   sourdine d'un canal (dans un mix, ou partout) ou
//                             d'un mix entier, image « on » / « off » selon
//                             l'état réel ;
//   com.moozydev.hanko.media  Spotify : lecture/pause, aléatoire, répétition,
//                             image selon l'état réel (MPRIS, via playerctl).
//
// État : OpenXLR par son API HTTP sur la socket Unix privée
// ($XDG_RUNTIME_DIR/openxlr/control.sock), toutes les 500 ms et juste après
// chaque appui ; Spotify toutes les secondes. Rien n'est lu tant qu'aucune
// touche concernée n'est affichée. Une image n'est renvoyée au Stream Deck que
// si elle a changé.
//
// Réglages d'une touche (settings) :
//   vol   { channel?, mix, delta, picto, canal, mixLabel }   (sans channel : le mix entier)
//   mute  { channel?, mix, on, off }   mix = un id de mix, ou "all" avec channel
//   media { kind: "playpause" | "shuffle" | "repeat" }
import fs from "node:fs";
import http from "node:http";
import path from "node:path";
import process from "node:process";
import { execFile } from "node:child_process";

const HERE = path.dirname(new URL(import.meta.url).pathname);
const TIMEOUT_MS = 2000;

function arg(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

// ── Palette Hanko (couleurs du thème actif quand elles sont lisibles) ────────
const palette = {
  "fond": "#121010", "fond-clair": "#1e1a19", "fond-tres-sombre": "#070606", "noir": "#000000",
  "creme": "#f1e7d6", "creme-sombre": "#c9bfae", "accent": "#ff4a1c", "gris": "#6b625a", "brun": "#b08458",
};
try {
  const home = process.env.HOME || "";
  const toml = fs.readFileSync(path.join(home, ".local/state/omarchy/current/theme/colors.toml"), "utf8");
  const pick = key => (toml.match(new RegExp(`^\\s*${key}\\s*=\\s*"(#[0-9a-fA-F]{6})"`, "m")) || [])[1];
  if (pick("accent")) palette.accent = pick("accent");
  if (pick("background")) palette.fond = pick("background");
  if (pick("foreground")) palette.creme = pick("foreground");
} catch {
  // Pas de thème lisible : la palette Vermillon par défaut suffit.
}
const resolveColors = svg => svg.replace(/var\(--([a-z-]+)\)/g, (m, name) => palette[name] || m);

// ── Fichiers du kit ─────────────────────────────────────────────────────────
const fileCache = new Map();
function readAsset(rel, encoding) {
  const key = rel + (encoding || "");
  if (!fileCache.has(key)) fileCache.set(key, fs.readFileSync(path.join(HERE, "assets", rel), encoding));
  return fileCache.get(key);
}
function pngDataUrl(rel) {
  try {
    return "data:image/png;base64," + readAsset(rel).toString("base64");
  } catch {
    return null;
  }
}

// ── Dessin d'une touche de volume à partir du gabarit ───────────────────────
function pictoInner(name) {
  try {
    const svg = readAsset(`pictos/${name}.svg`, "utf8");
    const inner = svg.replace(/^[\s\S]*?<svg[^>]*>/, "").replace(/<\/svg>\s*$/, "");
    return inner.replace(/currentColor/g, "var(--creme-sombre)");
  } catch {
    return "";
  }
}
function setAttr(svg, id, attr, value) {
  return svg.replace(new RegExp(`(<[a-z]+ id="${id}"[^>]*?)\\s${attr}="[^"]*"`), `$1 ${attr}="${value}"`);
}
function escapeXml(s) {
  return String(s).replace(/[<>&"]/g, c => ({ "<": "&lt;", ">": "&gt;", "&": "&amp;", "\"": "&quot;" })[c]);
}
function volImage({ level, muted, dir, picto, canal, mixLabel }) {
  let svg = readAsset(`templates/vol-${dir}.svg`, "utf8");
  const pct = Math.max(0, Math.min(150, Math.round(level * 100)));
  const shown = Math.round(Math.min(1, Math.max(0, level)) * 10) / 10;  // segments entiers
  svg = setAttr(svg, "jauge", "height", (58 * shown).toFixed(2));
  svg = setAttr(svg, "jauge", "y", (7 + 58 * (1 - shown)).toFixed(2));
  if (muted) svg = svg.replace(/(<rect id="jauge"[^>]*?style=")fill:var\(--creme\)/, "$1fill:var(--gris)");
  const c = Math.floor(pct / 100), d = Math.floor(pct / 10) % 10, u = pct % 10;
  svg = setAttr(svg, "valeur-c", "href", `#d${c}`);
  svg = setAttr(svg, "valeur-d", "href", `#d${d}`);
  svg = setAttr(svg, "valeur-u", "href", `#d${u}`);
  const vis = (id, hidden) => {
    svg = svg.replace(new RegExp(`(<use id="${id}"[^>]*?)\\svisibility="hidden"`), "$1");
    if (hidden) svg = svg.replace(new RegExp(`<use id="${id}"`), `<use id="${id}" visibility="hidden"`);
  };
  vis("valeur-c", c === 0);
  vis("valeur-d", c === 0 && d === 0);
  if (muted) svg = svg.replace(/<g id="etat-coupe" display="none">/, "<g id=\"etat-coupe\">");
  if (picto) {
    svg = svg.replace(/<g id="picto">[\s\S]*?<\/g><\/g>/,
      `<g id="picto"><g transform="translate(7 7) scale(0.75)">${pictoInner(picto)}</g></g>`);
  }
  svg = svg.replace(/(<text id="canal"[^>]*>)[^<]*(<\/text>)/, `$1${escapeXml(canal || "")}$2`);
  svg = svg.replace(/(<text id="mix"[^>]*>)[^<]*(<\/text>)/, `$1${escapeXml(mixLabel || "")}$2`);
  return "data:image/svg+xml;base64," + Buffer.from(resolveColors(svg)).toString("base64");
}

// ── OpenDeck ────────────────────────────────────────────────────────────────
const keys = new Map();  // context -> { action, settings, image }
const host = new WebSocket(`ws://127.0.0.1:${arg("-port")}`);
host.onopen = () => host.send(JSON.stringify({ event: arg("-registerEvent"), uuid: arg("-pluginUUID") }));
host.onclose = () => process.exit(0);
const send = message => {
  if (host.readyState === WebSocket.OPEN) host.send(JSON.stringify(message));
};
const kindOf = action => action.split(".").pop();

function show(context, image) {
  const key = keys.get(context);
  if (!key || !image || key.image === image) return;
  key.image = image;
  send({ event: "setImage", context, payload: { image, target: 0 } });
}

host.onmessage = ({ data }) => {
  let m;
  try {
    m = JSON.parse(data);
  } catch {
    return;
  }
  const { event, context, action, payload } = m;
  if (event === "willAppear" || event === "didReceiveSettings") {
    keys.set(context, { action, settings: (payload && payload.settings) || {}, image: null });
    send({ event: "setTitle", context, payload: { title: "", target: 0 } });
    refresh();
  } else if (event === "willDisappear") {
    keys.delete(context);
  } else if (event === "keyDown") {
    press(context).catch(() => send({ event: "showAlert", context }));
  }
};

// ── OpenXLR ─────────────────────────────────────────────────────────────────
const socketPath = path.join(process.env.XDG_RUNTIME_DIR || `/run/user/${process.getuid()}`, "openxlr", "control.sock");
function api(method, url, body) {
  return new Promise((resolve, reject) => {
    const req = http.request({ socketPath, path: url, method, timeout: TIMEOUT_MS,
      headers: body ? { "Content-Type": "application/json" } : {} }, res => {
      let text = "";
      res.on("data", chunk => { text += chunk; });
      res.on("end", () => {
        if (res.statusCode >= 400) return reject(new Error(`HTTP ${res.statusCode}`));
        try { resolve(text ? JSON.parse(text) : {}); } catch (e) { reject(e); }
      });
    });
    req.on("timeout", () => req.destroy(new Error("timeout")));
    req.on("error", reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}
async function command(payload) {
  const r = await api("POST", "/api/v1/commands", payload);
  if (!r.ok) throw new Error(JSON.stringify(r.messages || r));
}

let mixer = null;  // { channels: Map, mixes: Map }
async function readMixer() {
  const state = await api("GET", "/api/v1/state");
  const m = state.mixer || {};
  mixer = {
    channels: new Map((m.channels || []).map(c => [c.id, c])),
    mixes: new Map((m.mixes || []).map(x => [x.id, x])),
  };
}

// Niveau et sourdine que montre une touche (null : inconnu).
function soundOf(s) {
  if (!mixer) return null;
  if (s.channel) {
    const ch = mixer.channels.get(s.channel);
    if (!ch) return null;
    const muted = new Set(ch.mutedIn || []);
    if (s.mix === "all") {
      const mixes = Object.keys(ch.levels || {});
      return { level: null, muted: mixes.length > 0 && mixes.every(x => muted.has(x)), mixes };
    }
    const level = ch.levels ? ch.levels[s.mix] : undefined;
    if (typeof level !== "number") return null;
    const mixMuted = !!(mixer.mixes.get(s.mix) || {}).muted;
    return { level, muted: muted.has(s.mix) || mixMuted, channelMuted: muted.has(s.mix) };
  }
  const mix = mixer.mixes.get(s.mix);
  if (!mix || typeof mix.volume !== "number") return null;
  return { level: mix.volume, muted: !!mix.muted, monitor: mix.kind === "monitor" };
}

// ── Spotify (MPRIS) ─────────────────────────────────────────────────────────
function playerctl(args) {
  return new Promise(resolve => {
    execFile("playerctl", ["-p", "spotify", ...args], { timeout: TIMEOUT_MS }, (err, out) => resolve(err ? null : String(out).trim()));
  });
}
let media = { status: null, shuffle: null, loop: null };
async function readMedia() {
  const [status, shuffle, loop] = await Promise.all([playerctl(["status"]), playerctl(["shuffle"]), playerctl(["loop"])]);
  media = { status, shuffle, loop };
}

// ── Images ──────────────────────────────────────────────────────────────────
function render(context) {
  const key = keys.get(context);
  if (!key) return;
  const s = key.settings;
  const kind = kindOf(key.action);
  if (kind === "vol") {
    const snd = soundOf(s);
    if (!snd) return;
    show(context, volImage({ level: snd.level, muted: snd.muted, dir: Number(s.delta) < 0 ? "moins" : "plus",
      picto: s.picto, canal: s.canal, mixLabel: s.mixLabel }));
  } else if (kind === "mute") {
    const snd = soundOf(s);
    if (!snd) return;
    show(context, pngDataUrl(`mute/${snd.muted ? s.off : s.on}.png`));
  } else if (kind === "media") {
    let file = null;
    if (s.kind === "playpause") file = media.status === "Playing" ? "media-lecture--lecture" : "media-lecture--pause";
    else if (s.kind === "shuffle") file = media.shuffle === "On" ? "media-aleatoire--on" : "media-aleatoire--off";
    else if (s.kind === "repeat") file = { Playlist: "media-repetition--playlist", Track: "media-repetition--titre" }[media.loop] || "media-repetition--off";
    if (file) show(context, pngDataUrl(`media/${file}.png`));
  }
}

let busy = false;
async function refresh() {
  if (busy) return;
  busy = true;
  try {
    const kinds = new Set([...keys.values()].map(k => kindOf(k.action)));
    if (kinds.has("vol") || kinds.has("mute")) await readMixer().catch(() => { mixer = null; });
    if (kinds.has("media")) await readMedia();
    for (const context of keys.keys()) render(context);
  } finally {
    busy = false;
  }
}
setInterval(refresh, 500);

// ── Appuis ──────────────────────────────────────────────────────────────────
const clamp = (v, hi) => Math.round(Math.min(hi, Math.max(0, v)) * 100) / 100;

async function press(context) {
  const key = keys.get(context);
  if (!key) return;
  const s = key.settings;
  const kind = kindOf(key.action);
  if (kind === "vol" || kind === "mute") {
    await readMixer();
    const snd = soundOf(s);
    if (!snd) throw new Error("état OpenXLR inconnu");
    if (kind === "vol") {
      const delta = Number(s.delta) / 100;
      if (s.channel) await command({ cmd: "setLevel", channel: s.channel, mix: s.mix, value: clamp(snd.level + delta, 1) });
      else await command({ cmd: "setMixVolume", mix: s.mix, value: clamp(snd.level + delta, snd.monitor ? 1.5 : 1) });
    } else if (s.channel && s.mix === "all") {
      for (const mix of snd.mixes) await command({ cmd: "setChannelMuted", channel: s.channel, mix, value: !snd.muted });
    } else if (s.channel) {
      await command({ cmd: "setChannelMuted", channel: s.channel, mix: s.mix, value: !snd.channelMuted });
    } else {
      await command({ cmd: "setMixMuted", mix: s.mix, value: !snd.muted });
    }
  } else if (kind === "media") {
    if (s.kind === "playpause") await playerctl(["play-pause"]);
    else if (s.kind === "shuffle") await playerctl(["shuffle", "toggle"]);
    else if (s.kind === "repeat") {
      const next = { None: "Playlist", Playlist: "Track" }[media.loop] || "None";
      await playerctl(["loop", next]);
    }
  }
  busy = false;
  await refresh();
}

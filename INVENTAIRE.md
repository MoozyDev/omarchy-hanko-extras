# Inventaire

Légende : ✅ déjà fait (zip d'origine) · 🆕 fait dans ce zip · ❌ pas fait (raison)
Zips d'origine : **A** = `omarchy-hanko` · **B** = écran de veille · **C** = `omarchy-suite`

## Par variante (× 3 : vermillon, cramoisi, vert-billard)
- [x] ✅ A — `colors.toml` complet (mode, 4 backgrounds, 4 foregrounds, accent, selection, muted, 8 couleurs + bright_)
- [x] ✅ A — `icons.theme` : Yaru-red (vermillon, cramoisi), Yaru-sage (vert-billard)
- [x] ✅ A — `preview.png`
- [x] 🆕 — `unlock.png` : remplacé par le logo Moozy (C) ; `preview-unlock.png` refait avec ce logo
- [x] ✅ A + C — Fonds 01, 02 (refaits en HANKO), 03 (A) et 04, 05 (C), chacun en 3840×2160 + `-vertical` 2160×3840
- [x] ✅ A — 10 icônes de web apps, PNG 512
- [x] 🆕 — **13 icônes de logiciels**, PNG 512 + SVG (`apps/`, `apps/svg/`). Chatterino, Terminal et Fichiers : silhouettes (pas de logo dans Simple Icons ou logo non pertinent)
- [x] ✅ A — `boot/limine.conf` (clés Limine 12.9.4, hex sans #) ; `boot/limine-fond.png` facultatif
- [x] 🆕 — `boot/plymouth.md` : fond = `fond` de la variante, texte = #121010
- [x] ✅ C, 🆕 corrigé — Spotify : `button` passe en crème, accent seulement sur le titre en cours (11e) ; `user.css` ajouté
- [x] ✅ C — Vesktop : `hanko-<variante>.theme.css`
- [x] ✅ C, 🆕 corrigé — Obsidian : accent seulement au survol des liens et sur les cases cochées (11e)
- [x] ✅ A, 🆕 complété — `couleurs-hors-palette.md` (noms communs ajoutés)
- [x] 🆕 — `README.md` en anglais + résumé en français

## Commun (`extras/`)
- [x] ✅ C, 🆕 complété — Logo Moozy : SVG grand format V1 et V2 (`moozy-v1-grand.svg`, `moozy-v2-grand.svg`), barre 24×24, PNG Plymouth crème et noir, `about.txt` ; kit complet V1/V2 (SVG + PNG de 14 à 1000 px) et `GUIDE.md`
- [x] ✅ A — 26 icônes de barre, 🆕 + 17 nouvelles : wifi-0…3, volume-low/medium/high, battery-0/25/50/75/100, battery-charging, bluetooth-off, screen-record, camera, idle-inhibit ; 🆕 `correspondance.md`
- [x] ✅ A — Anton + licence OFL + `LISEZMOI.md`
- [ ] ❌ — Glyphes « SpaceMono Hanko » : aucun glyphe n'a été ajouté à Space Mono ; les icônes Nerd Font du paquet suffisent, et nos icônes sont en SVG. Rien à fournir.
- [x] ✅ C — `fastfetch/config.jsonc`
- [x] ✅ C — Sons : `notification.wav` = **A** (tic court, refait), `verrouillage.wav` = **B** (< 1 s)
- [x] ✅ A — `looknfeel.md`
- [x] 🆕 — Fiches : barre, verrouillage (horizontal + vertical + 1 écran), widgets (écrans 1 à 4 + 1 seul écran + règles 16:10 et 21:9), fond par écran, 10 animations de veille, OSD, lanceur B, notifications, Twitch « EN DIRECT »
- [x] ✅ — Maquettes jouables (`specs/maquettes/`) : thème, directions, écran de veille (B), suite 11a–11f, charte du logo
- [x] 🆕 — Maquettes 16:10, 21:9 et double écran 21:9 + vertical (`specs/maquettes/hanko-formats.dc.html`)

## Publication
- [x] 🆕 — Nom public : **Hanko**, version 1.0.0
- [x] 🆕 — Bannières 1920×1080 × 3 + `comparatif-3-variantes.png`
- [x] 🆕 — Avatars 800×800 × 3 (logo Moozy V1)

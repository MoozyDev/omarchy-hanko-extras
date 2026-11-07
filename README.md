# Hanko · Extras — Omarchy

Shared assets and specs for the **Hanko** theme for [Omarchy](https://omarchy.org): a minimal, editorial theme in three variants.

![Hanko — three variants](presentation/comparatif-3-variantes.png)

| Variant | Repository |
|---|---|
| Vermillon | [omarchy-hanko-vermillon-theme](https://github.com/MoozyDev/omarchy-hanko-vermillon-theme) |
| Cramoisi | [omarchy-hanko-cramoisi-theme](https://github.com/MoozyDev/omarchy-hanko-cramoisi-theme) |
| Vert billard | [omarchy-hanko-vert-billard-theme](https://github.com/MoozyDev/omarchy-hanko-vert-billard-theme) |

Each variant installs on its own:

```
omarchy-theme-install https://github.com/MoozyDev/omarchy-hanko-vermillon-theme
```

## What is in this repo
- `fonts/` — Anton (SIL OFL 1.1). The system font is `ttf-space-mono-nerd` from the Arch repos.
- `logo/` — Moozy logo, V1 and V2, SVG + PNG from 14 to 1000 px, usage guide.
- `icons/bar/` — 45 monochrome 24×24 SVG bar icons + `correspondance.md` (icon → Omarchy widget).
- `branding/` — `about.txt`, `screensaver.txt`.
- `fastfetch/` — `config.jsonc`.
- `sounds/` — `notification.wav`, `verrouillage.wav` (lock).
- `looknfeel.md` — window borders, gaps, blur, animations, cursor.
- `specs/` — one spec per component to build in QML (bar, lock screen, desktop widgets, per-screen wallpaper, screensaver, OSD, launcher, notifications, Twitch live badge) + interactive mockups.
- `presentation/` — banners, comparison image, avatars.

## Status
**1.0.0 — work in progress.** The three themes work today. The install script and the QML components described in `specs/` are being written; until then this repo holds the assets and the design specs.

---

**En français** — Dépôt commun du thème Hanko : police, logo Moozy, icônes de barre, sons, fastfetch, et les fiches des éléments à coder (barre, verrouillage, widgets, écran de veille…). Les 3 variantes s'installent seules depuis leur dépôt. Le script d'installation des extras arrive dans une prochaine version. Détails : `SOMMAIRE.md` et `INVENTAIRE.md`.

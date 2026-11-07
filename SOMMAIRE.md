# Hanko 1.0.0 — zip final

Thème Omarchy minimaliste et éditorial, 3 variantes (Vermillon, Cramoisi, Vert billard), logo Moozy.

## Rangement
- `themes/<variante>/` — **un dossier = un dépôt GitHub**, autonome : copié seul dans `~/.config/omarchy/themes/`, il fonctionne.
- `extras/` — commun à toutes les variantes, ou à coder : 2ᵉ dépôt avec un script d'installation.
- `presentation/` — bannières, comparatif, avatars.
- `INVENTAIRE.md` — checklist remplie · `CREDITS.md` — licences.

## Couleurs (par nom)
| Nom | Vermillon | Cramoisi | Vert billard |
|---|---|---|---|
| `fond` | #e8431c | #c8102e | #0d6b3e |
| `accent` | #ff4a1c | #ff3355 | #36d27e |
| `accent-fonce` | #c2340f | #a50d26 | #0a5a33 |
| `noir` | #121010 | #121010 | #121010 |
| `creme` | #f1e7d6 | #f1e7d6 | #f1e7d6 |

## Fait ou corrigé dans ce zip
- 13 icônes d'applications (PNG 512 + SVG) dans les 3 variantes.
- Logo Moozy à la place de HANKO pour le déverrouillage (`unlock.png`, `preview-unlock.png`) ; SVG grand format V1 et V2.
- 17 nouvelles icônes de barre (niveaux wifi, volume, batterie, charge, Bluetooth coupé, enregistrement, caméra, inhibiteur de veille) + `correspondance.md`.
- Spotify et Obsidian : moins d'accent (11e).
- `plymouth.md`, README de chaque variante, fiches de tous les éléments à coder, bannières, comparatif, avatars.
- Tout est rangé et renommé en minuscules, sans accent ni espace (sauf les noms imposés par les applis, ex. `com.obsproject.Studio.png`).

## Ce que Claude Code doit coder
| Élément | Fiche | Effort |
|---|---|---|
| Installer les variantes + script de bascule (web apps, apps, Spicetify, Vesktop, Obsidian suivent la variante) | — | faible |
| Polices, `looknfeel.lua`, branding, fastfetch | `extras/` | faible |
| Limine + Plymouth (une fois, thème principal) | `boot/` | faible |
| Barre : icônes + bouton Moozy | `specs/barre` | moyen |
| OSD volume / luminosité | `specs/osd` | faible |
| Lanceur B | `specs/lanceur` | faible |
| Notifications + son | `specs/notifications` | faible |
| Sons (notification A, verrouillage B) | `extras/sounds` | faible |
| Verrouillage par écran | `specs/verrouillage` | moyen |
| Fond par écran | `specs/fond-par-ecran` | moyen |
| Widgets du bureau (1 à 4 écrans) | `specs/widgets-bureau` | moyen |
| Écran de veille QML, 10 animations | `specs/ecran-de-veille` | moyen à élevé |
| Twitch « EN DIRECT » (option) | `specs/twitch-en-direct` | élevé |

## Pas vérifié
- Spotify, Vesktop et Obsidian dans les vrais logiciels (noms de variables et classes CSS qui changent selon les versions).
- La disponibilité des noms sur GitHub.
- Le rendu des icônes de barre à 14–16 px sur l'écran réel.

## Nom et version
**Hanko** (判子, le sceau japonais : un disque rouge sur papier) — version **1.0.0**.
Dépôts : `omarchy-hanko-vermillon-theme`, `omarchy-hanko-cramoisi-theme`, `omarchy-hanko-vert-billard-theme`, `omarchy-hanko-extras`.
Versionnage sémantique : 1.0.1 = correction, 1.1.0 = ajout (nouveau fond, nouvelle icône), 2.0.0 = changement qui casse l'installation. Chaque dépôt a son `VERSION` et son `CHANGELOG.md`.

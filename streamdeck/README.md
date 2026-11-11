# Stream Deck · icônes Hanko

Touches 72 × 72 (viewBox 0 0 72 72), exportées en SVG + PNG 144 × 144. Angles droits partout.

## Familles : teinte ET forme
| Famille | Fond | Signe de forme | Rôle |
|---|---|---|---|
| **MUTE** | `accent` plein (son actif) | **Coupé** : fond noir, cadre orange 3 px, picto gris barré d'une oblique orange, « COUPÉ » | couper / rétablir |
| **VOL** | `fond-tres-sombre` | **Enfoncée** : biseau (bord haut-gauche noir, bas-droit `fond-clair`), jauge à 10 segments à droite, chiffres vectorisés | +5 % / −4 % |
| **NAV** | `creme` (catégories) · `creme-sombre` (page préc./suiv., retour, accueil) | **Coin plié** en haut à droite (orange sur l'accueil) | navigation |
| **MEDIA** | `brun` (actif) / `fond-clair` (désactivé) | Liseré bas 3 px | Spotify |
| **JEU** | `fond` | Nom du jeu en Anton + petit tampon carré orange, filet orange | lancer un jeu |
| **APP / ACTION** | `fond-clair` | Picto crème centré | OBS, dictée, veille, Steam |
| **TOUCHE** | `fond` | Dessin de touche de clavier (dessus, socle, contour beige) ; le libellé passe avant la combinaison | raccourcis |
| **MACRO** | `fond-tres-sombre` | Cadre en pointillés | emplacement libre |

Orange = couper. Foncé = volume. Crème/beige = navigation. Les familles restent distinctes même en niveaux de gris (forme + motif).

## Polices
- Icônes fixes : Anton (titres) et JetBrains Mono (libellés), avec repli `Impact` / `monospace`. **Les PNG contiennent déjà les bonnes polices** : préfère les PNG dans OpenDeck.
- Gabarits dynamiques : les chiffres sont **vectorisés** (symboles `#d0`…`#d9`), aucun besoin de police.

## Ce que Claude Code doit coder
| Tâche | Effort |
|---|---|
| Copier `icons/**.png` dans OpenDeck selon `correspondance.md` | faible |
| Touches multi-états (MUTE, MEDIA, veille, Steam, OBS) : changer d'image selon l'état OpenXLR / Spotify (MPRIS) / OBS | moyen |
| Plugin VOL : à chaque changement OpenXLR, réécrire `templates/vol-*.svg` (voir `templates/fiches/vol.md`), rasteriser en PNG 144 et pousser l'image sur la touche | moyen à élevé |
| Vumètre en direct (≈ 10–15 images/s max pour ne pas saturer l'USB) | élevé (optionnel) |
| Pochette Spotify derrière lecture/pause (`templates/media-lecture.svg`, `#pochette`) | moyen |
| Variantes Cramoisi / Vert billard : changer les variables CSS des gabarits, ou recolorer les PNG | faible |

## Non vérifié
- Le rendu sur l'écran réel du Stream Deck (contraste, netteté des textes de 6–7 px : les sous-libellés gris sont peut-être trop fins, à grossir si besoin).
- Que OpenDeck accepte `<use href>` et `clip-path` dans un SVG : si non, rasteriser côté plugin avant d'envoyer (recommandé de toute façon).
- Les logos de marque : j'ai mis des pictos génériques (bulle pour Discord, cercle d'enregistrement pour OBS, texte pour Steam). Pour les vrais logos, Claude Code peut prendre les SVG Simple Icons (CC0) en monochrome.

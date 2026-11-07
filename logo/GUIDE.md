# Moozy — guide du logo

Version : 9b-1 « Fidèle », novembre 2026. Deux orientations : **V1** (chevron vers la droite) et **V2** (même logo tourné de 90° dans le sens des aiguilles d'une montre).

## Contenu du dossier
```
moozy-logo-kit/
├── GUIDE.md                       ← ce fichier
├── Moozy-guide-logo-V1.pdf        ← guide illustré V1 (11 pages)
├── Moozy-guide-logo-V2.pdf        ← guide illustré V2 (11 pages)
├── Moozy-logo-V1-V2.vectorcraft   ← fichier source, un plan de travail par logo (96)
├── V1/  et  V2/
│   ├── neutre/          ← versions sans couleur de thème
│   ├── vermillon/
│   ├── cramoisi/
│   └── vert-billard/
│       └── <nom>/
│           ├── <nom>.svg
│           └── <nom>-x14.png … <nom>-x1000.png
```
Tailles PNG : 14, 16, 20, 24, 32, 48, 96, 180, 1000 px (le côté le plus long). Sous 24 px de logo, la version **petite taille** (fentes plus larges) est utilisée automatiquement.

## Les fichiers
| Dossier | Contenu | Fond |
|---|---|---|
| symbole-noir / symbole-creme | le symbole seul | transparent |
| symbole-couleur / symbole-accent | symbole en couleur du thème / accent | transparent |
| principale | noir sur la couleur du thème — **version par défaut** | couleur |
| couleur-sur-noir | couleur du thème sur noir | noir |
| negatif | crème sur noir | noir |
| positif | noir sur crème | crème |
| creme-sur-couleur | crème sur la couleur du thème | couleur |
| monochrome | noir pur sur blanc (impression N&B) | blanc |
| contour-creme / contour-noir | version contour (≥ 48 px) | noir / couleur |
| mixte | D plein, pièces en contour (état « hors ligne ») | noir |
| avatar-rond / avatar-carre | Twitch, Discord / GitHub, X | couleur |
| icone-appli | carré noir, disque couleur, logo noir | noir |
| icone-telephone | carré arrondi noir, logo couleur | transparent autour |
| horizontal / vertical | symbole + MOOZY | noir / couleur |
| ligne-activite | symbole + MOOZY + « RÉPARATION · RÉSEAUX · DESIGN » | crème |

## Construction (en % du rayon R ; D = 2 R)
- Cercle de rayon R, centre O.
- Pointe T du chevron à **0,62 R** à droite de O, sur l'axe horizontal (V1).
- Bras du chevron à **±36°**.
- Fentes : **x = 0,21 R = 0,105 D**, identiques en haut et en bas. La fente du bas continue jusqu'au bord du cercle.
- Arrondis : **0,32 R** sur le D, **0,11 R** sur les deux pièces (rapport 3:1).
- Petite taille (14–23 px) : fentes à **1,3 x**.

## Règles
- **Zone de protection** : 2 x autour du cercle.
- **Taille minimum** : 14 px à l'écran, 6 mm en impression.
- **Contour** : trait = **D × 0,035** (x / 3), aligné à l'intérieur, vectorisé avant export. Jamais sous 48 px, jamais en barre ni en avatar.
  Exemples : D 100 → 3,5 px · 512 → 17,9 · 785 → 27,5 · 1000 → 35 · 2048 → 71,7.
- **Dans un cadre** : logo à 60 % du cadre. Compensation optique : V1 décalée de 3 % du diamètre vers la droite, V2 de 3 % vers le bas.
- **Avec le nom** : horizontal → diamètre = hauteur des capitales × 1,1, espace 2 x. Vertical → largeur du nom = diamètre × 1,4.
- **Orientation** : 0° (V1) ou 90° (V2) uniquement. Une seule orientation par support.
- **À ne pas faire** : étirer, autre angle, deux couleurs, miroir, ombre / lueur / dégradé, couleur trop proche du fond.

## Polices
- **Anton** (Google Fonts, licence OFL) — nom MOOZY et titres. Capitales, une seule graisse.
- **Space Mono Bold** (Google Fonts, OFL) — ligne d'activité, étiquettes, interface. Capitales, interlettrage +20 %.

## Couleurs
| Nom | HEX | RGB |
|---|---|---|
| Noir | `#121010` | 18, 16, 16 |
| Crème | `#F1E7D6` | 241, 231, 214 |
| Blanc | `#FFFFFF` | 255, 255, 255 |
| Noir pur (impression) | `#000000` | 0, 0, 0 |

| Variante | Fond (HEX · RGB) | Accent (HEX · RGB) | Foncé (HEX · RGB) |
|---|---|---|---|
| Vermillon | `#E8431C` · 232, 67, 28 | `#FF4A1C` · 255, 74, 28 | `#C2340F` · 194, 52, 15 |
| Cramoisi | `#C8102E` · 200, 16, 46 | `#FF3355` · 255, 51, 85 | `#A50D26` · 165, 13, 38 |
| Vert billard | `#0D6B3E` · 13, 107, 62 | `#36D27E` · 54, 210, 126 | `#0A5A33` · 10, 90, 51 |

- **Fond** : couleur du disque et des grands aplats.
- **Accent** : petits éléments sur fond noir (bouton de barre, bureau actif) — plus vif que le fond.
- **Foncé** : petits textes de couleur sur fond crème (contraste suffisant).

## Fichier VectorCraft
`Moozy-logo-V1-V2.vectorcraft` : deux calques « Logo V1 » et « Logo V2 », un sous-calque et un plan de travail par fichier du kit (nommés « V1 · vermillon · principale », etc.). Les contours y sont de vrais contours **intérieurs** modifiables. Le texte MOOZY est vectorisé (pas besoin de la police pour l'ouvrir).

# Écran de veille « Hanko » — 11 animations (QML)

Remplace l'écran de veille ASCII d'Omarchy par une fenêtre QML plein écran. Elle s'ouvre après 150 s d'inactivité et se ferme au moindre mouvement de souris ou appui sur une touche.
Prototypes jouables : `Ecran de veille Hanko.dc.html` (projet Claude Design).

## Règles communes
- Couleurs nommées, lues dans le thème actif : `fond` (couleur des images de la variante, voir couleurs-hors-palette.md), `accent` (colors.toml), `crème` = foreground #f1e7d6, `noir` = background #121010.
- Tailles en % de la hauteur H (écran horizontal) ou de la largeur W (écran vertical, hauteur > largeur).
- Anti-marquage : tout le contenu (pas le fond) dérive en continu de ±1,2 % sur 180 s, en linéaire : (0,0) → (+1.2 %, −0.8 %) → (−0.6 %, +1 %) → (−1.2 %, −0.4 %) → (0,0).
- Pas de flash : aucun fondu de moins de 1,2 s.
- À chaque démarrage, une animation est tirée au hasard, différente de la précédente. Exception : Phases 6d-1 et 6d-3 ne se suivent jamais (si l'une vient de passer, les deux sont exclues). Chaque écran affiche sa propre version (horizontale ou verticale).
- Police : Anton (commun/fonts). Aucun fichier image nécessaire.

```
ÉCLIPSE · cycle 48 s · fond de l'écran = fond
ÉLÉMENTS
  disque   noir, Ø 55 % H, centre (x 20 %, y 50 %)       — sous le texte
  mot A    « HANKO », Anton, crème, corps 46 % H, centré
  mot B    même mot au même endroit, couleur accent, visible seulement dans le disque (masque circulaire)
TIMELINE   courbe bézier(0.45, 0, 0.55, 1)
  0 → 24 s     disque  x 20 % → 80 %
  24 → 48 s    disque  x 80 % → 20 %
               le masque du mot B suit exactement le centre du disque
ALÉATOIRE  à chaque cycle : sens de départ (gauche ou droite) ; hauteur du disque y 42–58 %
VERTICAL   disque Ø 70 % W, x 50 %, y 25 % ↔ 75 % ; mot « SIG / NAL » sur 2 lignes, corps 37 % W, interligne 0.9
EFFORT     faible — un cercle animé + le même cercle comme masque (clip / OpacityMask)
```

```
BALAYAGE · cycle 30 s · fond de l'écran = noir
ÉLÉMENTS
  ligne    accent, 2 px (≈ 0.1 % H), toute la hauteur, part de x 10 %
  mot      « HANKO », Anton, crème, corps 39 % H, centré dans la zone x 10–90 %
TIMELINE   courbe bézier(0.4, 0, 0.6, 1) sauf mention
  0 → 8 s      ligne  x 10 % → 90 %
  0 → 8 s      mot    découpe de gauche à droite, le bord suit la ligne (masque rectangle, largeur 0 → 100 %)
  8 → 9 s      ligne  opacité 1 → 0
  8 → 28 s     mot    interlettrage 0 → 0.06 em (mouvement lent, anti-marquage)
  22 → 28 s    mot    opacité 1 → 0
  28 → 30 s    écran noir vide
ALÉATOIRE  à chaque cycle : position verticale du mot y 30–70 % ; sens du balayage (gauche→droite ou droite→gauche)
VERTICAL   ligne horizontale, y 15 % → 85 % ; mot « SIG / NAL », corps 36 % W, révélé de haut en bas
EFFORT     faible — un rectangle qui glisse + un clip rectangulaire synchronisé
```

```
ONDE · cycle 24 s · fond de l'écran = fond
ÉLÉMENTS
  disque   noir, Ø 40 % H, centre (50 %, 50 %)              — au-dessus des cercles
  mot      « HANKO », Anton, crème, corps 11 % H, centré dans le disque
  cercles  3 contours crème, trait 0.15 % H (constant, ne grossit pas), même Ø que le disque au départ
TIMELINE
  en boucle 8 s   disque + mot  échelle 1 → 1.03 → 1   bézier(0.45, 0, 0.55, 1)
  chaque cercle   durée 12 s, un nouveau cercle toutes les 4 s (décalages 0 / 4 / 8 s)
                  Ø × 1 → × 3.4 ; opacité 0.8 → 0      bézier(0.2, 0.6, 0.3, 1) (départ vif, arrivée lente)
ALÉATOIRE  à chaque cycle : intervalle entre cercles 3.5–5 s ; centre du disque déplacé de ±8 % (x et y) avec un glissement de 6 s
VERTICAL   disque Ø 56 % W, centre (50 %, 50 %) ; mot « SIG / NAL », corps 15 % W
EFFORT     faible — cercles QML (Rectangle radius) avec rayon et opacité animés
```

```
FRÉQUENCE · cycle 40 s · fond de l'écran = noir
ÉLÉMENTS
  lettres  S I G N A L, Anton, crème, corps 43 % H, une lettre = un élément, rangée centrée
  ligne    accent, 2 px, largeur 70 %, 18 px (≈ 3 % H) sous les lettres
TIMELINE   lettres : bézier(0.65, 0, 0.35, 1) ; ligne : linéaire
  0 → 6 s      tout aligné, ligne visible
  6 → 14 s     chaque lettre glisse vers son décalage A (en % de la hauteur de la lettre)
  14 → 24 s    chaque lettre glisse vers son décalage B
  24 → 32 s    retour à l'alignement (0)
  32 → 40 s    tout aligné
               décalages A : S −60  I +40  G −25  N +70  A −45  L +20
               décalages B : S +35  I −50  G +60  N −30  A +45  L −65
  4.8 → 7.2 s  ligne  opacité 1 → 0
  30.8 → 33.2 s ligne opacité 0 → 1
ALÉATOIRE  à chaque cycle : nouveaux décalages A et B tirés entre −70 % et +70 % (deux lettres voisines jamais dans le même sens)
VERTICAL   lettres empilées en colonne, corps 25 % W, interligne 0.95 ; elles glissent à l'horizontale (mêmes valeurs, en % de la largeur de la lettre) ; ligne verticale 82 % de haut à gauche de la colonne
EFFORT     moyen — 6 animations indépendantes + tirage des décalages
```

```
MARÉE · cycle 40 s · fond de l'écran = fond
ÉLÉMENTS
  mot A    « HANKO », Anton, noir, corps 46 % H, centré              — sous la marée
  marée    surface noire ondulée, pleine largeur (déborde de 4 % de chaque côté), du niveau N jusqu'en bas
           vague irrégulière : somme de 3 sinusoïdes sur une boucle de 1200 px (à 1080 p), amplitude totale ±1.9 % H
           forme fournie : commun/screensaver/maree-vague.svg (remplissage) + maree-surface.svg (trait)
  surface  trait accent 2.5 px qui suit exactement la vague
  mot B    même mot, crème, visible seulement sous la surface (même forme de vague utilisée comme masque)
TIMELINE
  0 → 40 s     vague  glisse vers la gauche d'une boucle complète (1200 px) en 40 s, linéaire, en continu
  0 → 20 s     niveau N  y 72 % → 28 %   (la marée monte)     courbe cosinus (douce aux extrémités)
  20 → 40 s    niveau N  y 28 % → 72 %   (elle redescend)
               marée, trait et masque du mot B partagent la même position : toujours alignés
ALÉATOIRE  à chaque cycle : niveaux haut 22–34 % et bas 66–78 % ; phases des 3 sinusoïdes tirées au hasard (forme de vague différente à chaque fois)
NOTE       la forme déborde de ses bords (x −20 → 1220) pour éviter toute ligne de raccord visible
VERTICAL   mot « SIG / NAL », corps 37 % W ; même vague, mêmes niveaux en % de la hauteur
EFFORT     faible à moyen — Shape QML (PathCubic/PathQuad) qui glisse + même forme en masque (OpacityMask / layer.effect)
```

```
ORBITE · cycle 60 s (une minute réelle) · fond de l'écran = fond
ÉLÉMENTS
  disque   noir, Ø 60 % H, centre (50 %, 46 %)
  heure    « HH:MM », Anton, crème, corps 23 % H, centrée dans le disque
  orbite   cercle noir, trait 1 px, opacité 0.35, Ø 70 % H, même centre
  point    noir, Ø 3 % H, posé sur l'orbite
  date     « JEUDI 05 NOV », Space Mono 700, crème, corps 2.4 % H, interlettrage 0.3 em, y 86 %
TIMELINE
  en continu   point  angle = secondes × 6°, départ à midi (en haut), linéaire — calé sur l'horloge réelle
  à chaque minute  heure  fondu enchaîné ancienne → nouvelle, 1.2 s, bézier(0.45, 0, 0.55, 1)
ALÉATOIRE  aucun (l'anti-marquage vient de la dérive et du changement de chiffres)
VERTICAL   disque Ø 79 % W, orbite Ø 91 % W ; heure sur 2 lignes « HH / MM », corps 28 % W ; date y 82 %
NOTE       le point et l'orbite sont noirs (et non accent) : sur Vermillon, l'accent se confond avec le fond
EFFORT     faible — rotation + horloge système (Timer QML 1 s)
```

```
DÉFILEMENT · boucle sans fin (bandeaux de 50 à 80 s) · fond de l'écran = noir
ÉLÉMENTS
  bandeau  « HANKO ● HANKO ● … » sur une ligne, Anton, corps 28 % H, interligne 1
           séparateur = disque plein Ø 0.22 em, espace 0.3 em de chaque côté
           le motif est répété 2 fois de suite pour une boucle sans raccord
  rangées  3, centrées verticalement : crème / accent / crème
TIMELINE   linéaire, en continu
  rangée 1     x 0 → −1 motif en 60 s (vers la gauche)
  rangée 2     x −1 motif → 0 en 80 s (vers la droite)
  rangée 3     x 0 → −1 motif en 70 s (vers la gauche)
ALÉATOIRE  au démarrage : décalage de départ de chaque rangée (0–100 % du motif) ; vitesses ±15 %
VERTICAL   5 rangées, corps 32 % W : crème / crème / accent / crème / crème ; vitesses 50 · 65 · 80 · 55 · 70 s, sens alternés
EFFORT     faible — Row de Text dans un Item qui glisse (x animé)
```

```
PHASES · cycle 48 s · fond de l'écran = fond
ÉLÉMENTS
  lune     disque noir, Ø 52 % H, centre (50 %, 44 %)
  ombre    disque, même Ø, même hauteur que la lune — 2 versions, comptées comme 2 animations du tirage :
           6d-1  couleur = fond, AU-DESSUS de la lune (invisible hors de la lune)
           6d-3  « trou » — 3 plans, de l'arrière vers l'avant :
                   1. fond noir plein écran
                   2. cercle fond assombri, qui se déplace
                   3. plaque plein écran couleur fond, percée d'un trou rond (Ø 52 % H, centre 50 % / 44 %)
                 → le cercle n'est visible qu'à travers le trou ; le reste du temps on voit un trou noir
                 cercle : fond + 14 % de noir (Qt.darker(fond, 1.18))
                 QML : plaque = Shape avec un chemin (rectangle + cercle, fillRule OddEvenFill)
TIRAGE     6d-1 et 6d-3 sont deux entrées séparées, mais jamais l'une juste après l'autre :
           si la précédente était 6d-1 ou 6d-3, les deux sont exclues du tirage suivant
  mot      « HANKO », Anton, crème, corps 10 % H, centré, y 76 %
TIMELINE   courbe bézier(0.45, 0, 0.55, 1)
  0 → 48 s     ombre  x −160 % → +160 % (en % de son diamètre, par rapport à la lune)
               → plein, croissant décroissant, nouvelle lune (vers 24 s), croissant, plein
  0 → 2 s      ombre  opacité 0 → 1 (elle apparaît loin à gauche)
  46 → 48 s    ombre  opacité 1 → 0 (elle disparaît loin à droite)
ALÉATOIRE  à chaque cycle : sens (gauche→droite ou droite→gauche) ; légère inclinaison de la trajectoire ±10°
VERTICAL   lune Ø 70 % W, centre (50 %, 42 %) ; mot corps 15 % W, y 70 %
EFFORT     faible — deux cercles, un seul animé (les 2 versions ne diffèrent que par la couleur et l'ordre d'empilement)
```

```
TRAME · cycle 10 s par point, vague continue · fond de l'écran = noir
ÉLÉMENTS
  grille   32 colonnes × 18 rangées sur tout l'écran ; un point par case, Ø 1.7 % H
  couleur  accent si le point est dans un cercle de rayon 5.6 cases autour du centre (le « disque »), crème sinon
TIMELINE   courbe bézier(0.45, 0, 0.55, 1), en boucle
  chaque point  échelle 0.3 → 1 → 0.3 et opacité 0.35 → 1 → 0.35, sur 10 s
  décalage      (colonne + rangée) × 0.22 s → la vague traverse l'écran en diagonale
ALÉATOIRE  à chaque cycle de 60 s : direction de la vague (4 diagonales) ; centre du disque déplacé de ±3 cases
VERTICAL   12 colonnes × 21 rangées ; disque de rayon 4.8 cases au centre
EFFORT     moyen — 576 points (Repeater QML) ; vérifier la fluidité en 4K, sinon revenir à 24 × 14
```

```
VINYLE · un tour en 20 s · fond de l'écran = fond · branché sur le lecteur média (MPRIS)
ÉLÉMENTS
  disque     noir, Ø 67 % H, centre (50 %, 42 %)
  sillons    7 cercles concentriques crème, trait 1 px, opacité 0.14
  texte      « HANKO · HANKO · HANKO · » en cercle (rayon 29 % H), Space Mono 700, crème, corps 2.8 % H
  pochette   image du morceau en cours (mpris:artUrl), découpée en rond, Ø 28 % H — tourne avec le disque
             sans pochette : rond de la couleur accent, vide
  titre      « TITRE — ARTISTE », Space Mono 700, crème, corps 2.2 % H, interlettrage 0.2 em, y 81 %
  commandes  y 87 % : précédent (icône noire) · lecture/pause (rond crème Ø 9.6 % H, icône noire) · suivant (icône noire)
             icônes : commun/icons/bar/media-prev.svg, media-play.svg, media-pause.svg, media-next.svg
TIMELINE
  en lecture   disque + pochette  rotation 0 → 360° en 20 s, linéaire
  pause        la rotation ralentit jusqu'à l'arrêt en 1.2 s (bézier 0.2, 0.6, 0.3, 1) ; reprise : accélère en 1.2 s
  changement de morceau  pochette et titre en fondu enchaîné 1.2 s
ALÉATOIRE  au démarrage : angle de départ 0–360°
SI RIEN NE JOUE  cette animation est exclue du tirage
⚠ COMMANDES  l'écran de veille se ferme au moindre mouvement de souris : impossible de cliquer.
             → les boutons montrent l'état ; on les pilote avec les touches média du clavier (lecture, suivant, précédent),
               que l'écran de veille doit laisser passer SANS se fermer. Le bouton touché s'éclaire 300 ms (icône → accent).
VERTICAL   disque Ø 84 % W, centre y 38 % ; pochette Ø 34 % W ; titre y 68 % ; commandes y 76 %
EFFORT     moyen — texte en cercle + lecture MPRIS + gestion des touches média
```

## Ordre conseillé
1. Éclipse — 2. Orbite — 3. Onde — 4. Phases (6d-1 et 6d-3) — 5. Balayage — 6. Défilement (faibles) — 7. Marée (faible à moyen) — 8. Vinyle — 9. Fréquence — 10. Trame (moyens).

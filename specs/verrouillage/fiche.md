# Écran de verrouillage — effort moyen (copie de `omarchy.lock`)
Maquettes : ouvrir `../maquettes/directions.dc.html` (écran de verrouillage de la direction 1c) et `hanko-suite.dc.html` → **11b**.

- Une surface par écran ; rôle selon l'**orientation** (hauteur > largeur = vertical).
- **Vertical** : grande horloge Anton `creme` « HH / mm » empilée, centrée, 38 % de la largeur ; date SpaceMono 14 px sous l'horloge.
- **Horizontal** : titre HANKO (comme le fond 01), date + météo + musique en bas (mêmes positions que les widgets du bureau), pas de grande horloge.
- **Un seul écran** : horloge Anton en bas à gauche (4 % / 7 %), 18 % de la hauteur.
- Fond : le fond d'écran actif, **sans flou**, assombri de 35 %.
- Champ : rectangle `noir` 320×44, bordure 2 px `creme`, points carrés 8 px `creme` ; erreur = bordure `accent` + secousse 3 × 6 px en 240 ms.
- Son : `extras/sounds/verrouillage.wav` au verrouillage.

# Widget « EN DIRECT » Twitch — option — effort élevé
Maquettes : ouvrir `../maquettes/hanko-suite.dc.html` → **11b**, écran 4.

- Haut gauche de l'écran 4 (4 % / 6 %). Pastille `accent` 12 px qui pulse (1 → 0,4, 2 s) + « EN DIRECT » SpaceMono 700 14 px `creme`.
- Dessous : titre du stream, catégorie, nombre de spectateurs, durée (SpaceMono 13 px, `gris`).
- Hors ligne : widget masqué.
- Données : API Twitch Helix (`streams?user_login=moozycore`), jeton d'appli requis ; interrogation toutes les 60 s.

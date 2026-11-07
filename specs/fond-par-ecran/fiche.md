# Fond différent par écran — effort moyen (copie de `omarchy.background`)
- Fichiers par paires dans `backgrounds/` : `NN-nom.png` (3840×2160) + `NN-nom-vertical.png` (2160×3840).
- Écran vertical (hauteur > largeur) : charger `<fond courant>-vertical.png` s'il existe, sinon l'horizontal recadré.
- Rôles 1 à 4 (voir `widgets-bureau/fiche.md`) : écran 2 → `05-papier-vertical`, écran 4 → `04-moozy`, autres → fond courant.
- Garder le raccourci d'Omarchy « fond suivant » : il fait tourner le fond courant ; les rôles fixes (écrans 2 et 4) peuvent être désactivés dans le plugin.

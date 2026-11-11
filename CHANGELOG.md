# Changelog

## Non publié
- Correctif « un fond par écran » : si `hanko.background` est installé mais a perdu son activation (le drapeau vit dans `shell.json`, que d'autres outils réécrivent), le démarrage suivant retombait sur le fond unique d'Omarchy. L'écran vertical reprenait alors le fond du thème, recadré depuis la version horizontale : barre orange du fond « papier » coupée. `hanko.desktop` le réactive maintenant au démarrage, et `hanko doctor` / `hanko fonds status` signalent « installé mais désactivé ».

## 1.2.0 — 2026-11-11
- Un fond d'écran par écran (`hanko fonds`, plugin `hanko.background`, copie de `omarchy.background`) : un double-clic sur le bureau, le sélecteur de fonds ou « fond suivant » ne changent que l'écran choisi (celui du double-clic, sinon celui qui a le focus). Un changement de thème remet le fond du thème partout. Choix gardés dans `~/.local/state/hanko/backgrounds.json`.
- Écran vertical : la version `vertical/NN-nom-vertical.png` du fond est affichée quand le thème la fournit.
- Fond HANKO dessiné (`hanko.desktop`) : suit maintenant le fond de chaque écran au lieu du fond commun.
- Horloge de l'écran vertical : heures, point clignotant et minutes sur trois lignes (le point était collé aux heures) ; décalée de 40 px vers la droite.

## 1.1.0 — 2026-11-07
- Installation en une commande (`install.sh`) et commande `hanko` (install, doctor, update, uninstall).
- Barre qui grandit au survol (copie de la barre Omarchy + patch réversible).
- Menu large et bas, choix B (copie du menu Omarchy + patch réversible).
- Écran de veille Hanko : Éclipse, Orbite, Onde, Balayage, Défilement, Phases.
- Écran de verrouillage Hanko : horloge Anton, date, champ déplacé, sans flou, son, secousse en cas d'erreur ; accroche remise après chaque mise à jour d'Omarchy (hook pacman).
- Logo ASCII de veille : HANKO (au lieu de SIGNAL).

## 1.0.0 — 2026-11-07
Première version publique.

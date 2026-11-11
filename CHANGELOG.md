# Changelog

## Non publié
- Plugin Stream Deck Hanko 1.1 : action OBS (scène avec son nom écrit sur la touche, live et enregistrement avec leur état réel, clip = sauvegarde du replay), via `streamdeck/bin/obs-deck` (obs-cmd + obs-websocket ; mot de passe lu dans la config d'obs-websocket, jamais recopié). `streamdeck/bin/openxlr-vol` ajouté au dépôt.
- Barre qui grandit au survol : le contenu grandit aussi (icônes, textes, boutons). Les sections gauche, centre et droite d'une barre horizontale sont agrandies du même rapport que la barre (32 → 50 px, soit ×1,56), chacune depuis son côté ; clics, info-bulles et panneaux suivent. `hanko bar on` remplace l'ancienne version du patch.
- … sans jamais se chevaucher : la taille est plafonnée à ce qui tient entre la gauche, le centre et la droite (calcul en continu). Si même la taille normale ne tient pas (écran étroit ou vertical, titre de musique long, icônes cachées dépliées), le contenu est réduit (jusqu'à ×0,5) au lieu de déborder.
- Correctif « un fond par écran » : si `hanko.background` est installé mais a perdu son activation (le drapeau vit dans `shell.json`, que d'autres outils réécrivent), le démarrage suivant retombait sur le fond unique d'Omarchy. L'écran vertical reprenait alors le fond du thème, recadré depuis la version horizontale : barre orange du fond « papier » coupée. `hanko.desktop` le réactive maintenant au démarrage, et `hanko doctor` / `hanko fonds status` signalent « installé mais désactivé ».
- Correctif `hanko.desktop` : la barre charge une copie du widget par écran sans lui dire son écran, si bien que toutes les copies travaillaient. Résultat : fenêtres de widgets superposées (6 au lieu de 2 sur 3 écrans) et météo téléchargée 3 fois. Une seule copie travaille désormais (`Registry.js`, bibliothèque partagée).
- Kit Stream Deck Hanko (`streamdeck/`) : 110 icônes par familles (sourdine orange, volume « enfoncé », navigation crème avec coin plié, Spotify, jeux, apps, raccourcis façon touche de clavier, macros), tous les états, gabarits dynamiques, aperçus et correspondance touche → fichier (livraison Claude Design v2).
- Plugin OpenDeck `com.moozydev.hanko` (`streamdeck/plugin/`) : touches vivantes. Volume OpenXLR avec jauge à 10 segments et valeur en direct, calque « COUPÉ » ; sourdines OpenXLR avec leur état réel ; Spotify lecture/pause, aléatoire, répétition selon MPRIS. Couleurs du thème actif.
- Icônes de barre v2 (Claude Design) : 19 icônes redessinées pour 16 px (trait de 1,5 px sur une grille de 16, contre-formes ouvertes) : Bluetooth (vraie rune), micro (capsule), son, Wi-Fi, réseau filaire, alimentation, notifications, mises à jour ; la météo a maintenant 5 icônes (soleil, nuit, nuage, pluie, coucher de soleil) choisies selon le temps. Ajout de `cpu` et `memory` pour plus tard.
- États « coupé » lisibles : Bluetooth coupé, son coupé et micro coupé ont leur barre / croix en orange. Le point d'accroche des icônes accepte une deuxième forme `"accent"` dans `map.json`, dessinée par-dessus dans la couleur d'accent.

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

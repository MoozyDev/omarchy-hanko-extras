# Correspondance touches → fichiers

- Chaque fichier existe en `.svg` (72×72, viewBox 0 0 72 72) et `.png` (144×144).
- Plusieurs états = plusieurs fichiers : `nom--etat`. Le 1er état listé est l'état par défaut.
- **Raccourcis B = Raccourcis A** (mêmes fichiers). Une touche non listée reste vide.

| Profil | Touche | Famille | Fichier(s) | États / dynamique |
|---|---|---|---|---|
| Base | L1 C4 | NAV | `icons/nav/` nav-musique | — |
| Base | L1 C5 | NAV | `icons/nav/` nav-jeux | — |
| Base | L2 C1 | APP | `icons/app/` app-veille--eveille, app-veille--eteint | eveille / eteint |
| Base | L2 C3 | NAV | `icons/nav/` nav-raccourcis | — |
| Base | L2 C4 | NAV | `icons/nav/` nav-discord | — |
| Base | L2 C5 | NAV | `icons/nav/` nav-micros | — |
| Base | L3 C3 | NAV | `icons/nav/` page-suiv-obs | — |
| Base | L3 C4 | NAV | `icons/nav/` nav-systeme | — |
| Base | L3 C5 | NAV | `icons/nav/` nav-obs | — |
| OBS | L1 C5 | NAV | `icons/nav/` page-suiv-micros | — |
| OBS | L2 C2 | NAV | `icons/nav/` page-prec-base | — |
| OBS | L2 C5 | MEDIA | `icons/media/` media-suivant | — |
| OBS | L3 C3 | APP | `icons/app/` app-obs | — |
| OBS | L3 C5 | NAV | `icons/nav/` nav-base | — |
| Micros | L1 C1 | NAV | `icons/nav/` nav-mix-stream | — |
| Micros | L1 C2 | MUTE | `icons/mute/` mute-mix-chat--on, mute-mix-chat--off | on / off |
| Micros | L1 C4 | MUTE | `icons/mute/` mute-mix-vocgame--on, mute-mix-vocgame--off | on / off |
| Micros | L1 C5 | NAV | `icons/nav/` nav-mix-casque | — |
| Micros | L2 C2 | VOL | `icons/vol/` vol-mix-chat-plus--normal, vol-mix-chat-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Micros | L2 C4 | VOL | `icons/vol/` vol-mix-vocgame-plus--normal, vol-mix-vocgame-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Micros | L2 C5 | NAV | `icons/nav/` page-suiv-discord | — |
| Micros | L3 C1 | NAV | `icons/nav/` page-prec-obs | — |
| Micros | L3 C2 | VOL | `icons/vol/` vol-mix-chat-moins--normal, vol-mix-chat-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Micros | L3 C4 | VOL | `icons/vol/` vol-mix-vocgame-moins--normal, vol-mix-vocgame-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Micros | L3 C5 | NAV | `icons/nav/` nav-base | — |
| Discord | L2 C3 | TOUCHE | `icons/touche/` touche-overlay | — |
| Discord | L3 C2 | MUTE | `icons/mute/` mute-micro-chat--on, mute-micro-chat--off | on / off |
| Discord | L3 C3 | MUTE | `icons/mute/` mute-discord-casque--on, mute-discord-casque--off | on / off |
| Discord | L3 C4 | TOUCHE | `icons/touche/` touche-super-1 | — |
| Discord | L3 C5 | NAV | `icons/nav/` nav-base | — |
| Musique | L1 C1 | MUTE | `icons/mute/` mute-browser-tous--on, mute-browser-tous--off | on / off |
| Musique | L1 C5 | NAV | `icons/nav/` page-suiv-jeux | — |
| Musique | L2 C1 | VOL | `icons/vol/` vol-browser-casque-plus--normal, vol-browser-casque-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Musique | L2 C2 | MEDIA | `icons/media/` media-aleatoire--off, media-aleatoire--on | off / on |
| Musique | L2 C3 | MEDIA | `icons/media/` media-lecture--pause, media-lecture--lecture | pause / lecture |
| Musique | L2 C4 | MEDIA | `icons/media/` media-repetition--off, media-repetition--playlist, media-repetition--titre | off / playlist / titre |
| Musique | L2 C5 | TOUCHE | `icons/touche/` touche-super-6 | — |
| Musique | L3 C1 | VOL | `icons/vol/` vol-browser-casque-moins--normal, vol-browser-casque-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Musique | L3 C2 | NAV | `icons/nav/` page-prec-discord | — |
| Musique | L3 C5 | NAV | `icons/nav/` nav-base | — |
| Jeux | L1 C1 | NAV | `icons/nav/` nav-valo | — |
| Jeux | L1 C2 | NAV | `icons/nav/` nav-minecraft | — |
| Jeux | L1 C3 | NAV | `icons/nav/` nav-gta | — |
| Jeux | L1 C4 | NAV | `icons/nav/` nav-cyberpunk | — |
| Jeux | L1 C5 | NAV | `icons/nav/` page-suiv-systeme | — |
| Jeux | L2 C1 | JEU | `icons/jeu/` jeu-phasmophobia | — |
| Jeux | L2 C2 | JEU | `icons/jeu/` jeu-cs2 | — |
| Jeux | L2 C3 | JEU | `icons/jeu/` jeu-sparking-zero | — |
| Jeux | L2 C4 | JEU | `icons/jeu/` jeu-elden-ring | — |
| Jeux | L2 C5 | JEU | `icons/jeu/` jeu-ark | — |
| Jeux | L3 C1 | TOUCHE | `icons/touche/` touche-alt-f4 | — |
| Jeux | L3 C2 | APP | `icons/app/` app-steam-offline--inactif, app-steam-offline--actif | inactif / actif |
| Jeux | L3 C3 | APP | `icons/app/` app-dictee | — |
| Jeux | L3 C4 | APP | `icons/app/` app-steam-online--inactif, app-steam-online--actif | inactif / actif |
| Jeux | L3 C5 | NAV | `icons/nav/` nav-base | — |
| Système | L2 C1 | NAV | `icons/nav/` page-prec-jeux | — |
| Système | L2 C5 | NAV | `icons/nav/` page-suiv-raccourcis | — |
| Système | L3 C1 | TOUCHE | `icons/touche/` touche-super-3 | — |
| Système | L3 C2 | TOUCHE | `icons/touche/` touche-super-4 | — |
| Système | L3 C3 | TOUCHE | `icons/touche/` touche-super-5 | — |
| Système | L3 C4 | TOUCHE | `icons/touche/` touche-ctrl-maj-echap | — |
| Système | L3 C5 | NAV | `icons/nav/` nav-base | — |
| Raccourcis A / B | L1 C1 | TOUCHE | `icons/touche/` touche-espace | — |
| Raccourcis A / B | L1 C2 | TOUCHE | `icons/touche/` touche-l | — |
| Raccourcis A / B | L1 C3 | TOUCHE | `icons/touche/` touche-ctrl-k | — |
| Raccourcis A / B | L2 C1 | TOUCHE | `icons/touche/` touche-ctrl-z | — |
| Raccourcis A / B | L2 C2 | TOUCHE | `icons/touche/` touche-ctrl-maj-z | — |
| Raccourcis A / B | L2 C3 | TOUCHE | `icons/touche/` touche-haut | — |
| Raccourcis A / B | L2 C4 | TOUCHE | `icons/touche/` touche-bas | — |
| Raccourcis A / B | L3 C1 | TOUCHE | `icons/touche/` touche-gauche | — |
| Raccourcis A / B | L3 C2 | TOUCHE | `icons/touche/` touche-droite | — |
| Raccourcis A / B | L3 C3 | TOUCHE | `icons/touche/` touche-q | — |
| Raccourcis A / B | L3 C4 | TOUCHE | `icons/touche/` touche-suppr | — |
| Raccourcis A / B | L3 C5 | NAV | `icons/nav/` nav-base | — |
| Mix Stream | L1 C1 | NAV | `icons/nav/` nav-retour-micros | — |
| Mix Stream | L1 C2 | MUTE | `icons/mute/` mute-discord-stream--on, mute-discord-stream--off | on / off |
| Mix Stream | L1 C3 | MUTE | `icons/mute/` mute-music-stream--on, mute-music-stream--off | on / off |
| Mix Stream | L1 C4 | MUTE | `icons/mute/` mute-game-stream--on, mute-game-stream--off | on / off |
| Mix Stream | L1 C5 | MUTE | `icons/mute/` mute-browser-stream--on, mute-browser-stream--off | on / off |
| Mix Stream | L2 C1 | VOL | `icons/vol/` vol-sfx-stream-plus--normal, vol-sfx-stream-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Stream | L2 C2 | VOL | `icons/vol/` vol-discord-stream-plus--normal, vol-discord-stream-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Stream | L2 C3 | VOL | `icons/vol/` vol-music-stream-plus--normal, vol-music-stream-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Stream | L2 C4 | VOL | `icons/vol/` vol-game-stream-plus--normal, vol-game-stream-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Stream | L2 C5 | VOL | `icons/vol/` vol-browser-stream-plus--normal, vol-browser-stream-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Stream | L3 C1 | VOL | `icons/vol/` vol-sfx-stream-moins--normal, vol-sfx-stream-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Stream | L3 C2 | VOL | `icons/vol/` vol-discord-stream-moins--normal, vol-discord-stream-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Stream | L3 C3 | VOL | `icons/vol/` vol-music-stream-moins--normal, vol-music-stream-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Stream | L3 C4 | VOL | `icons/vol/` vol-game-stream-moins--normal, vol-game-stream-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Stream | L3 C5 | VOL | `icons/vol/` vol-browser-stream-moins--normal, vol-browser-stream-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Casque | L1 C1 | NAV | `icons/nav/` nav-retour-micros | — |
| Mix Casque | L1 C2 | MUTE | `icons/mute/` mute-discord-casque--on, mute-discord-casque--off | on / off |
| Mix Casque | L1 C3 | MUTE | `icons/mute/` mute-music-casque--on, mute-music-casque--off | on / off |
| Mix Casque | L1 C4 | MUTE | `icons/mute/` mute-game-casque--on, mute-game-casque--off | on / off |
| Mix Casque | L1 C5 | MUTE | `icons/mute/` mute-browser-casque--on, mute-browser-casque--off | on / off |
| Mix Casque | L2 C1 | VOL | `icons/vol/` vol-sfx-casque-plus--normal, vol-sfx-casque-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Casque | L2 C2 | VOL | `icons/vol/` vol-discord-casque-plus--normal, vol-discord-casque-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Casque | L2 C3 | VOL | `icons/vol/` vol-music-casque-plus--normal, vol-music-casque-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Casque | L2 C4 | VOL | `icons/vol/` vol-game-casque-plus--normal, vol-game-casque-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Casque | L2 C5 | VOL | `icons/vol/` vol-browser-casque-plus--normal, vol-browser-casque-plus--coupe | dynamique : `templates/vol-plus.svg` |
| Mix Casque | L3 C1 | VOL | `icons/vol/` vol-sfx-casque-moins--normal, vol-sfx-casque-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Casque | L3 C2 | VOL | `icons/vol/` vol-discord-casque-moins--normal, vol-discord-casque-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Casque | L3 C3 | VOL | `icons/vol/` vol-music-casque-moins--normal, vol-music-casque-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Casque | L3 C4 | VOL | `icons/vol/` vol-game-casque-moins--normal, vol-game-casque-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Mix Casque | L3 C5 | VOL | `icons/vol/` vol-browser-casque-moins--normal, vol-browser-casque-moins--coupe | dynamique : `templates/vol-moins.svg` |
| Valo | L1 C1 | NAV | `icons/nav/` nav-retour-jeux | — |
| Valo | L1 C2 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L1 C3 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L1 C4 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L1 C5 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L2 C1 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L2 C2 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L2 C3 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L2 C4 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L2 C5 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L3 C1 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L3 C2 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L3 C3 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L3 C4 | MACRO | `icons/macro/` macro-libre | — |
| Valo | L3 C5 | MACRO | `icons/macro/` macro-libre | — |
| Minecraft | L1 C1 | NAV | `icons/nav/` nav-retour-jeux | — |
| Minecraft | L1 C2 | TOUCHE | `icons/touche/` touche-menu-xray | — |
| Minecraft | L2 C2 | TOUCHE | `icons/touche/` touche-on-off | — |
| Minecraft | L3 C2 | TOUCHE | `icons/touche/` touche-auto-click | — |
| GTA | L1 C1 | NAV | `icons/nav/` nav-retour-jeux | — |
| GTA | L1 C2 | TOUCHE | `icons/touche/` touche-yimenu | — |
| GTA | L1 C3 | TOUCHE | `icons/touche/` touche-teleport-w | — |
| GTA | L1 C4 | TOUCHE | `icons/touche/` touche-teleport-o | — |
| Cyberpunk | L1 C1 | NAV | `icons/nav/` nav-retour-jeux | — |
| Cyberpunk | L1 C2 | TOUCHE | `icons/touche/` touche-menu | — |
| Cyberpunk | L1 C3 | TOUCHE | `icons/touche/` touche-teleport-w | — |
| Cyberpunk | L1 C4 | TOUCHE | `icons/touche/` touche-teleport-o | — |

## OBS (à venir)
| Fonction | Fichier(s) |
|---|---|
| Scène | `icons/app/obs-scene` (remplacer « NOM DE SCÈNE », ou laisser vide et utiliser le titre OpenDeck) |
| En direct | `icons/app/obs-live--hors-ligne`, `obs-live--en-direct` |
| Enregistrer | `icons/app/obs-enregistrer--arret`, `obs-enregistrer--enregistre` |
| Clip | `icons/app/obs-clip` |

## Génériques
- `icons/touche/touche-raccourci` : raccourci sans libellé (pour remplacer Super+1…6, Alt+F4, Ctrl+Maj+Échap quand ils changeront).
- `icons/macro/macro-libre` (avec « + LIBRE ») et `icons/macro/macro-vierge` (cadre seul, pour écrire dessus).

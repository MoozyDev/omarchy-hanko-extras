# Touches à plusieurs états

Une image par état dans `icons/` : il suffit de changer l'image de la touche.

| Touche | États (fichiers `--etat`) | Source de l'état |
|---|---|---|
| MUTE (toutes) | `on` (son actif, orange) · `off` (coupé) | OpenXLR : mute du canal/mix |
| VOL | `normal` · `coupe` (images figées à 50 % si pas de plugin) | OpenXLR |
| media-lecture | `pause` (affiche ▶) · `lecture` (affiche ⏸) | MPRIS Spotify |
| media-aleatoire | `off` · `on` | MPRIS Shuffle |
| media-repetition | `off` · `playlist` · `titre` | MPRIS LoopStatus (None / Playlist / Track) |
| app-veille | `eveille` · `eteint` | OpenDeck (luminosité 0) |
| app-steam-online / offline | `inactif` · `actif` (statut en cours) | Steam |
| obs-live | `hors-ligne` · `en-direct` | obs-websocket |
| obs-enregistrer | `arret` · `enregistre` | obs-websocket |

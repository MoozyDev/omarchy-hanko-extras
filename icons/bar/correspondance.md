# Icônes de la barre — correspondance
SVG 24×24, un seul `<path>` plein, `fill="currentColor"` (ou sans couleur) : la couleur vient du thème.

| Fichier(s) | Widget | Couleur |
|---|---|---|
| `menu` | Bouton menu (logo Moozy) | accent |
| `wifi-0 … wifi-3` | Réseau sans fil, 4 niveaux | creme |
| `wifi / wifi-off` | Wi-Fi (générique / coupé) | creme / gris |
| `network-wired` | Réseau filaire | creme |
| `tailscale` | Tailscale | creme ; accent si connecté à un nœud de sortie |
| `ai` | Agents IA | creme ; accent si actif |
| `bluetooth / bluetooth-off` (+ `bluetooth-off.accent`) | Bluetooth | creme / gris ; barre en accent |
| `volume-low/-medium/-high` | Son | creme |
| `volume / volume-mute` (+ `volume-mute.accent`) | Son (générique / muet) | creme ; croix en accent |
| `mic / mic-off` (+ `mic-off.accent`) | Micro | creme ; barre en accent |
| `headphones` | Sortie casque | creme |
| `brightness` | Luminosité (OSD) | creme |
| `display` | Écran | creme |
| `battery-0 … battery-100` | Batterie, 5 niveaux | creme ; battery-0 et 25 en accent |
| `battery-charging` | Batterie en charge | creme |
| `battery` | Batterie (générique) | creme |
| `power` | Alimentation | creme |
| `notifications / dnd` | Notifications / Ne pas déranger | creme / accent |
| `updates` | Mises à jour | accent quand il y en a |
| `weather-sun / -night / -cloud / -rain` ; `weather` (= coucher de soleil, temps inconnu) | Météo, selon le temps | creme |
| `keyboard` | Disposition clavier | creme |
| `music, media-prev/-play/-pause/-next` | Lecteur média | creme |
| `record / screen-record` | Enregistrement d'écran | accent |
| `camera` | Caméra utilisée | accent |
| `idle-inhibit` | Inhibiteur de veille | creme |
| `tray` | Zone des icônes d'applis | creme |

Ordre dans la barre : **gauche** menu, bureaux · **centre** indicateurs, horloge, clavier, météo, micro, média, mises à jour · **droite** tray, Tailscale, IA, Bluetooth, réseau, son, écran, alimentation.
Nouveaux dans ce zip : wifi-0…3, volume-low/medium/high, battery-0…100, battery-charging, bluetooth-off, screen-record, camera, idle-inhibit.

## v2 (11 nov. 2026)
19 icônes redessinées pour 16 px par Claude Design (voir CHANGELOG). Les fichiers `*.accent.svg` sont une deuxième forme superposée en `accent` (`map.json` : `{"file": "x.svg", "accent": "x.accent.svg"}`). Les 31 autres icônes restent en v1 en attendant la suite (`design/prompt-claude-design-icones-barre-suite.md`). `cpu` et `memory` ne sont encore reliées à aucun widget.

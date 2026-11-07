# Widgets du bureau — effort moyen (plugin maison sur la couche « arrière-plan »)
Maquettes : ouvrir `../maquettes/hanko-suite.dc.html` → **11b** (écrans 1, 2, 3, 4).

## Rôle de chaque écran (calculé, pas par nom)
| Cas | Écran | Fond | Widgets |
|---|---|---|---|
| 1 seul écran | écran 3 | 01-hanko | horloge + date + météo bas gauche (4 % / 7 %) ; musique bas droite (4 % / 7 %) |
| écran vertical | écran 2 | 05-papier-vertical (crème) | horloge Anton `noir` calée à gauche (7 %), point `fond` qui pulse (opacité 1 → 0,4, 2 s, sinus) ; À FAIRE ; jauges CPU/RAM/GPU/NET |
| écran le plus large | écran 1 | 01-hanko | météo bas gauche ; musique bas droite ; pas d'horloge |
| écran suivant | écran 4 | 04-moozy | MOOZY bas gauche ; « EN DIRECT » Twitch haut gauche (option) |

## Formats
Toutes les positions en % ; tailles de texte en % de la **hauteur** de l'écran.
- **16:9** : valeurs ci-dessus.
- **16:10** : identiques (la marge basse passe de 7 % à 6 %).
- **21:9** : widgets gauche à 6 % au lieu de 4 % ; musique à 6 % du bord droit ; le titre du fond reste centré (bande 9:16).
- Résolutions 1920×1080, 2560×1440, 3840×2160 : aucune différence (tout est proportionnel).

## Règles
- Pas de donnée = widget masqué (pas de cadre vide) : sans musique, sans météo, sans réseau.
- Étiquettes `noir` sur Vermillon ; `creme` sur Cramoisi et Vert billard (contraste).
- Jauge > 60 % : barre en `fond`, chiffre en `accent-fonce`.
- Masquables : tous ; par défaut seule l'horloge (1 écran) ou l'horloge verticale reste.
- Maquettes 16:9 / 16:10 / 21:9 / double écran 21:9 : `../maquettes/hanko-formats.dc.html` (sections 12b et 12c).
- Ratio = largeur ÷ hauteur : ≤ 1,7 → 16:10 · 1,7 à 2 → 16:9 · > 2 → 21:9. Musique : 22 % / 24 % / 17 % de la largeur. Tailles de texte en % de la hauteur : horloge 11 %, titre du morceau 4,4 %, étiquettes 1,7 %. Jauge SYSTÈME sur l'écran principal seulement en 21:9 sans écran vertical.

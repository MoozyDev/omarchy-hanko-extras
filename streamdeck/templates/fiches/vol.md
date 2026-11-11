# Gabarit VOL (`vol-plus.svg`, `vol-moins.svg`)

Couleurs en variables CSS dans le `<style>` du haut (`--fond`, `--creme`, `--accent`…).

| id | Rôle | Comment le faire bouger |
|---|---|---|
| `jauge` | remplissage (10 segments) | `height = 58 × niveau` et `y = 7 + 58 × (1 − niveau)` (niveau 0–1). Le `clip-path=url(#segs)` découpe en segments. Pour n'allumer que des segments entiers : arrondir niveau au dixième. |
| `valeur-c`, `valeur-d`, `valeur-u` | centaines / dizaines / unités | mettre `href="#dN"` (N = chiffre) ; `visibility="hidden"` sur les zéros de tête (ex. 7 → c et d cachés). |
| `vumetre` | son qui passe (option) | même formule que `jauge`, sur x = 65, en `--accent`. Hauteur 0 si silence. |
| `picto` | canal réglé | remplacer le contenu du `<g>` par `templates/pictos/<canal>.svg` (couleur `--creme-sombre`, `transform="translate(7 7) scale(.75)"`). |
| `canal`, `mix` | libellés (texte) | changer le texte (ex. « GAME » / « STREAM »). Police mono, repli `monospace`. |
| `etat-coupe` | calque « coupé » | retirer `display="none"` quand le canal est coupé ; passer aussi `#jauge` en `--gris`. |

Le signe + / − est figé (un gabarit par sens).

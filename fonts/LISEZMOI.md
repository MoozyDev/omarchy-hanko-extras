# Polices

- **Anton** (affichage) : `Anton-Regular.ttf` ci-joint, licence OFL. Installer dans `~/.local/share/fonts/` puis `fc-cache -f`.
  Sert aux fonds d'écran (déjà dessinés dans les PNG), à l'écran de verrouillage QML et au logo Plymouth (déjà dans le PNG).
  Toujours en capitales, jamais sous 32 px.
- **SpaceMono Nerd Font** (système, chasse fixe + icônes Nerd Font) : `sudo pacman -S ttf-space-mono-nerd`
  puis `omarchy font set "SpaceMono Nerd Font"` (vérifier le nom exact avec `fc-list | grep -i spacemono`).
  Tailles : barre 11 px capitales (interlettrage +8 %), terminal/éditeur 13 px interligne 1.6, lanceur 13 px, notifications 11 px.
  Gras (700) seulement pour l'élément actif et les titres ; jamais d'italique.

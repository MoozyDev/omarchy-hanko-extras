# Architecture et décisions

Vérifié sur Omarchy 4 (source du 7 novembre 2026, Hyprland 0.57, Quickshell).

## Vue d'ensemble

```text
curl … install.sh | bash -s <variante>
 └─ clone ce dépôt → ~/.local/share/hanko/extras, lien ~/.local/bin/hanko
     └─ hanko install <variante>
         ├─ thème       omarchy theme install …-<variante>-theme   (couleurs, fonds, icônes)
         ├─ extras      police Anton, icônes d'applis, logo ASCII, fastfetch  (sauvegarde avant)
         ├─ barre       clone omarchy.bar → $USER.bar + bar/bar-patch.sh
         ├─ menu        clone omarchy.menu → $USER.menu + menu/menu-patch.sh
         ├─ veille      ~/.config/omarchy/plugins/hanko.screensaver (widget de barre invisible)
         ├─ fonds       ~/.config/omarchy/plugins/hanko.background (copie de omarchy.background)
         ├─ verrouillage sudo lock/system.sh install
         │               ├─ /usr/local/lib/hanko/lock-patch.sh  → accroche dans LockView.qml
         │               ├─ /etc/pacman.d/hooks/hanko-lock.hook → la remet après chaque mise à jour
         │               └─ ~/.config/omarchy/lock-skin/Skin.qml (le skin, modifiable)
         └─ omarchy-restart-shell (le shell recompile ce qui a changé)
```

## Décisions

### 1. Un installeur à côté du thème, pas dans le thème
- **Décision** : le dépôt de variante ne contient que des couleurs et des images ; tout le code est installé par `hanko`.
- **Raison** : `omarchy theme install` retire volontairement d'un thème cloné tout ce qui exécute du code (`*.lua`, configs de terminaux, `vscode.json`). Une barre animée ne peut donc pas venir du thème.
- **Rejeté** : mettre du QML dans le thème (ignoré par Omarchy).

### 2. Barre et menu : copie officielle + patch marqué
- **Décision** : `omarchy plugin clone` crée une copie qu'Omarchy traite comme l'original (widgets intégrés intacts) ; un script remplace quelques lignes exactes, marquées `HANKO-BAR` / `HANKO-MENU`.
- **Raison** : écrire une barre complète tierce perdrait les services des widgets intégrés.
- **Sécurité** : si une ligne attendue n'existe plus (Omarchy a changé), le script ne modifie rien. `restore` remet le fichier d'origine (testé en aller-retour).
- **Barre** : la zone réservée aux fenêtres ne change pas ; seule la bande dessinée grandit (+18 px) au survol et passe par-dessus les fenêtres.

### 3. Écran de verrouillage : accroche dans un fichier système
- **Constat** : la vérification du mot de passe (`lock/Service.qml`, capacité `authentication`) est réservée aux plugins d'Omarchy. Un plugin tiers ou un clone ne peut pas remplacer le verrouillage.
- **Décision** : ajouter, dans `LockView.qml` (affichage seulement), un `Loader` qui charge `~/.config/omarchy/lock-skin/Skin.qml` s'il existe, et deux lignes marquées `HANKO-LOCK`. `Service.qml` n'est pas touché.
- **Mises à jour** : un hook pacman (`Type = Path`, cible `LockView.qml`) relance le patch après chaque mise à jour d'Omarchy.
- **Retour en arrière** : `hanko lock off` (sans sudo, skin retiré → écran par défaut) ; `hanko lock uninstall` (fichier d'origine + hook supprimé).
- **Sécurité** : une erreur dans le skin ne bloque pas le verrouillage (le `Loader` échoue seul). Le skin tourne dans la même fenêtre que la saisie : n'y mettre que du code de confiance.
- **Rejeté** : cloner `omarchy.lock` (perd l'authentification) ; remplacer `Service.qml` (risque de sécurité, inutile).

### 4. Écran de veille : widget de barre invisible
- **Constat** : un plugin de type `service` placé dans `~/.config/omarchy/plugins` ne se charge pas (« File name case mismatch ») ; remplacer `omarchy-launch-screensaver` par le PATH est impossible (le dossier `bin` d'Omarchy passe en premier) ; le drapeau `screensaver-off` n'est plus lu.
- **Décision** : le plugin est un widget de barre de 0 px qui surveille l'inactivité (`IdleMonitor`) et ouvre une fenêtre par écran. `hanko screensaver on` déplace le délai d'Omarchy (`idle.screensaver`) dans le réglage `delay` du widget et met celui d'Omarchy à 0. L'entrée Menu > Système > Screensaver est redirigée par `~/.config/omarchy/extensions/omarchy-menu.jsonc`.
- **IPC** : `omarchy-shell hanko-screensaver open|close|list`.

### 5. Fonds verticaux rangés à part
- **Décision** : les `*-vertical.png` des variantes sont dans `backgrounds/vertical/`.
- **Raison** : Omarchy ne liste que le premier niveau de `backgrounds/` et prend le premier fichier par ordre alphabétique ; `01-hanko-vertical.png` passait avant `01-hanko.png`.

### 6. Un fond d'écran par écran : copie du service de fond
- **Constat** : Omarchy n'a qu'un fond (`~/.local/state/omarchy/current/background`), dessiné à l'identique sur chaque écran par le service `omarchy.background`. Un plugin qui déclare `"omarchy": { "clonedFrom": "omarchy.background" }` le remplace une fois activé (vérifié le 11 nov. 2026 : il se charge, contrairement au service tiers du point 4, et reprend la cible IPC `background` après un redémarrage du shell).
- **Décision** : `plugins/hanko.background` = le `Background.qml` d'Omarchy, inchangé sauf les blocs marqués `Hanko` :
  - `background set` (appelé par `omarchy-theme-bg-set`, donc double-clic, sélecteur, « fond suivant ») ne change qu'un écran : celui du double-clic, sinon celui qui a le focus (`Hyprland.focusedMonitor`). Les autres écrans sont figés sur ce qu'ils montrent ;
  - `themeTransition`, `transition` et `setInstant` (changement de thème) remettent tous les écrans au fond commun ;
  - choix gardés dans `~/.local/state/hanko/backgrounds.json` (`{ "DP-2": "/chemin/image.png" }`), lu aussi par `hanko.desktop` ;
  - écran vertical : `…/vertical/<nom>-vertical.<ext>` s'il existe, sinon l'image horizontale recadrée ;
  - vidéos : restent communes (OWE les dessine sur tous les écrans).
- **IPC ajoutées** : `omarchy-shell background setScreen <écran> <image>`, `resetScreens`, `screens`.
- **Mises à jour d'Omarchy** : la copie ne suit pas les changements futurs de `omarchy.background`. Pour la refaire : recopier le `Background.qml` d'Omarchy et réappliquer les blocs `Hanko`. `hanko fonds off` remet le service d'origine.
- **Rejeté** : un widget de barre invisible qui dessine par-dessus le fond (doublerait chaque image en mémoire et ne capterait pas le double-clic) ; modifier `/usr/share/omarchy` (écrasé à chaque mise à jour).

## Points d'attention
- Après une modification de QML, le shell garde l'ancienne version compilée : `hanko` redémarre le shell quand il remplace un fichier.
- Une mise à jour d'Omarchy peut changer les lignes patchées : les scripts refusent alors d'écrire et `hanko doctor` montre `original`.

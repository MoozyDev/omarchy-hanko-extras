# Hanko — tutoriel

Le thème **Hanko** pour [Omarchy](https://omarchy.org) 4, en trois couleurs : `vermillon`, `cramoisi`, `vert-billard`.

Toutes les commandes se tapent dans un terminal Omarchy (**Super + Entrée**), en tant qu'utilisateur normal (pas `sudo`). Elles marchent aussi depuis une session SSH.

---

## 1. Installer

Choisis **un** des trois niveaux. Remplace `vermillon` par `cramoisi` ou `vert-billard` si tu préfères.

### La totale — tout le thème

```bash
curl -fsSL https://raw.githubusercontent.com/MoozyDev/omarchy-hanko-extras/main/install.sh | bash -s vermillon totale
```

Installe : couleurs, fonds d'écran, icônes, police Anton, logo, **barre qui grandit au survol**, **menu large**, **widgets du bureau** (horloge, météo, musique), **fond HANKO dessiné à la taille de l'écran**, **écran de veille animé**, **écran de verrouillage Hanko** et **écran de déverrouillage du disque**.
Il pose deux questions et demande ton mot de passe (`sudo`) pour l'écran de verrouillage et l'écran de démarrage. Réponds `o` pour oui.

### L'essentiel — l'apparence sans les plugins

```bash
curl -fsSL https://raw.githubusercontent.com/MoozyDev/omarchy-hanko-extras/main/install.sh | bash -s vermillon essentiel
```

Installe : couleurs, fonds d'écran, icônes des dossiers et des applications, polices Anton et Space Mono Nerd, curseur Bibata, bordures et animations des fenêtres, logo ASCII, fastfetch.
Ne touche pas à la barre, au menu, à la veille ni au verrouillage. Pas de `sudo`.

### Le thème seul — couleurs et fonds

```bash
curl -fsSL https://raw.githubusercontent.com/MoozyDev/omarchy-hanko-extras/main/install.sh | bash -s vermillon theme
```

Installe : couleurs, fonds d'écran, icônes des dossiers. Rien d'autre.
(Équivalent à `omarchy theme install https://github.com/MoozyDev/omarchy-hanko-vermillon-theme`.)

Après n'importe lequel des trois, la commande **`hanko`** est disponible pour ajouter ou retirer chaque partie.

---

## 2. Voir où tu en es

```bash
hanko doctor
```

Affiche l'état de chaque partie : thème actif, barre, menu, widgets, veille, verrouillage, et si le shell Omarchy répond.

---

## 3. Chaque partie, une par une

Chaque partie a `on` pour l'activer et `off` pour revenir à Omarchy d'origine.

### Thème et couleur

| Commande | Ce que ça fait |
|---|---|
| `hanko theme vermillon` | passe à la couleur Vermillon (ou `cramoisi`, `vert-billard`) |
| `hanko extras` | police Anton, icônes des applis et web apps, logo ASCII, fastfetch |

> Comment : `hanko theme` utilise la commande officielle `omarchy theme install`. `hanko extras` copie les fichiers et garde tes anciens dans `~/.local/share/hanko/backup`.

### Barre qui grandit au survol

```bash
hanko bar on
hanko bar off
```

La barre du haut fait 32 px, avec un filet de 1 px sous elle, et grandit de 18 px quand la souris passe dessus. Ses widgets sont rangés dans l'ordre Hanko (`hanko bar layout` pour les remettre en ordre). Les fenêtres ne bougent pas : la barre passe par-dessus.

> Comment : Hanko fait une copie officielle de la barre d'Omarchy (`omarchy plugin clone omarchy.bar`) et y change 4 lignes marquées `HANKO-BAR`. `off` remet la barre d'origine.

### Icônes Hanko dans la barre

```bash
hanko icons install     # une seule fois (demande sudo)
hanko icons on          # icônes Hanko
hanko icons off         # icônes Omarchy d'origine (sans sudo)
hanko icons uninstall   # tout retirer (demande sudo)
```

Son, micro, Wi-Fi, réseau, Bluetooth, batterie, écran, météo, Ne pas déranger, enregistrement, IA, mises à jour, et le bouton menu avec le logo Moozy en couleur accent. Une icône sans équivalent Hanko reste celle d'Omarchy.

> Comment : Omarchy dessine toutes les icônes de la barre avec un seul composant système. `hanko icons install` y ajoute un point d'accroche qui affiche ton SVG à la place du caractère, dans la même couleur ; un hook pacman le remet après chaque mise à jour. Les widgets gardent toutes leurs fonctions.

### Bureau actif et horloge

```bash
hanko barstyle install     # une seule fois (demande sudo)
hanko barstyle on          # pastille accent + horloge en capitales
hanko barstyle off         # style Omarchy (sans sudo)
hanko barstyle uninstall   # tout retirer (demande sudo)
```

Le bureau actif devient son numéro en noir sur une pastille de la couleur accent ; l'horloge passe en capitales.

> Comment : accroche dans les deux widgets système d'Omarchy (Bureaux et Horloge), remise par un hook pacman après chaque mise à jour. `on`/`off` changent un simple fichier, à chaud.

### Notifications et jauge volume / luminosité

```bash
hanko ui install     # une seule fois (demande sudo)
hanko ui on
hanko ui off
hanko ui uninstall
```

Notifications : nom de l'application en tête, en accent foncé ; bandeau accent sur les notifications urgentes ; elles glissent depuis la droite. Jauge (OSD) : en bas de l'écran, fond noir, barre fine accent pour le volume et crème pour la luminosité.

> Comment : accroche dans les deux fichiers système d'Omarchy, remise par un hook pacman ; `on`/`off` changent `~/.config/omarchy/hanko/ui.json`.

### Fenêtres

```bash
hanko looknfeel on
hanko looknfeel off
```

Bordures de 3 px (crème sur la fenêtre active, noires sinon), angles droits, espaces de 8 et 16 px, légère transparence, flou, animations sèches sans rebond.

> Comment : un bloc marqué dans ton `~/.config/hypr/looknfeel.lua` ; les couleurs des bordures viennent du thème.

### Curseur

```bash
hanko cursor on      # installe Bibata-Modern-Classic (fourni avec Hanko, sans sudo)
hanko cursor off
```

Complet après la prochaine connexion. La police Space Mono Nerd et le curseur sont fournis avec Hanko (licences dans `third-party/`) : rien à installer en plus.

### Menu large et bas

```bash
hanko menu on
hanko menu off
```

Le menu Omarchy (bouton en haut à gauche de la barre) prend la moitié de la largeur, montre 6 lignes et se centre un peu plus haut.

> Comment : copie officielle du menu d'Omarchy + 3 lignes marquées `HANKO-MENU`.

### Widgets du bureau et fond HANKO à la bonne taille

```bash
hanko widgets on
hanko widgets off
```

En bas à gauche : horloge, date, météo. En bas à droite : la musique en cours (seulement quand quelque chose joue). Un son joue à chaque notification (sauf en « Ne pas déranger »).
Quand le fond **01** ou **02** est choisi, le titre HANKO est redessiné à la taille exacte de ton écran : jamais coupé, jamais sous l'horloge.

Réglages :

```bash
omarchy bar set hanko.desktop weatherLocation Paris     # ville de la météo
omarchy bar set hanko.desktop weather false             # cacher la météo
omarchy bar set hanko.desktop music false               # cacher la musique
omarchy bar set hanko.desktop clock false               # cacher l'horloge
omarchy bar set hanko.desktop liveWallpaper false       # garder l'image d'origine des fonds 01 et 02
```

> Comment : un petit plugin (`hanko.desktop`) posé sur le fond d'écran, sous les fenêtres. Il ne bloque jamais un clic. La météo vient de wttr.in toutes les 30 minutes.

### Écran de veille animé

```bash
hanko screensaver on
hanko screensaver off
hanko screensaver test            # en lancer une tout de suite
hanko screensaver test orbite     # une animation précise
```

Animations : `eclipse`, `orbite`, `onde`, `balayage`, `defilement`, `phases`, `phases3`, `maree`, `frequence`, `trame`, `vinyle` (seulement quand une musique joue). Une au hasard à chaque fois. Elle se ferme au moindre mouvement de souris ou appui sur une touche (les touches média ne la ferment pas).

Changer le délai (en secondes, `0` = jamais) :

```bash
omarchy bar set hanko.screensaver delay 300
```

> Comment : un plugin (`hanko.screensaver`) surveille l'inactivité. La veille ASCII d'Omarchy est coupée (son délai passe à 0) et Menu > Système > Screensaver ouvre la veille Hanko. Le verrouillage automatique d'Omarchy reste inchangé.

### Écran de verrouillage

```bash
hanko lock install     # une seule fois (demande sudo)
hanko lock on          # active le skin Hanko
hanko lock off         # écran de verrouillage Omarchy par défaut (sans sudo)
hanko lock edit        # modifier le skin
hanko lock status
hanko lock uninstall   # tout retirer (demande sudo)
```

Grande horloge Anton, date, champ du mot de passe déplacé en bas, fond sans flou, son au verrouillage, secousse si le mot de passe est faux.
Pour déplacer le champ : `hanko lock edit`, puis change `fieldPosition` en haut du fichier (`"center"`, `"bottom"`, `"bottom-right"`, `"top"`…).

> Comment : Omarchy ne laisse aucun plugin remplacer son verrouillage (c'est lui qui vérifie le mot de passe). `hanko lock install` ajoute un seul point d'accroche dans le fichier d'**affichage** d'Omarchy ; la vérification du mot de passe n'est pas touchée. Un hook pacman le remet automatiquement après chaque mise à jour d'Omarchy. Si le skin a une erreur, Omarchy affiche son écran normal : tu ne restes jamais bloqué.

### Écran de déverrouillage du disque (au démarrage)

```bash
hanko boot on
hanko boot off
```

Fond vermillon, texte noir, logo Moozy à la place du logo Omarchy. Visible au prochain démarrage.

> Comment : commande officielle `omarchy plymouth set` (demande sudo).

---

## 4. Entretien

| Commande | Ce que ça fait |
|---|---|
| `hanko update` | récupère la dernière version de Hanko et réapplique ce qui est activé |
| `hanko uninstall` | retire tout et remet tes anciens fichiers |
| `omarchy-restart-shell` | redémarre le bureau Omarchy (barre, widgets, veille) sans fermer ta session |

**Quand redémarrer le shell ?** Les commandes `hanko` le font toutes seules quand il le faut. Si quelque chose ne change pas à l'écran après une modification, lance `omarchy-restart-shell` : la barre clignote une fois et tout est rechargé.

---

## 5. Dans une machine virtuelle (VMware)

Omarchy dans VMware affiche parfois un écran gris : le pilote graphique de VMware gère mal l'accélération des applications. Correctif, à faire une fois :

```bash
sed -i '/bootstrap.lua/a hl.env("LIBGL_ALWAYS_SOFTWARE", "1")' ~/.config/hypr/hyprland.lua
sudo reboot
```

Garde l'accélération 3D activée dans les réglages de la VM.

# Hanko — état face aux maquettes

Comparaison entre les maquettes et fiches de `specs/` et ce que l'installation fait réellement (vérifié dans une VM Omarchy 4, 1920×1080, un seul écran). Mis à jour le 8 novembre 2026.

✅ fait et vérifié · 🟡 fait en partie · ⬜ pas fait · ❔ fait mais pas vérifié

## Thème (couleurs, fonds, icônes)
| Élément | Source | État |
|---|---|---|
| Palette `colors.toml` des 3 variantes | `theme-ecrans` · Fiche technique | ✅ |
| Fonds 01 à 05, versions verticales à part | `theme-ecrans` · Fonds d'écran | ✅ |
| Fond HANKO dessiné à la taille de l'écran, logo Moozy noir à la place du disque | demande en cours de route | ✅ |
| Icônes Yaru-red / Yaru-sage (dossiers) | Polices, icônes, curseur | ✅ |
| Icônes des applis et des web apps | Icônes des web apps | ✅ |
| Polices Anton et Space Mono Nerd (fournies) | Polices en contexte | ✅ |
| Curseur Bibata Modern Classic (fourni) | Curseur | ✅ (installé ; rendu après reconnexion non vérifié) |

## Bureau
| Élément | Source | État |
|---|---|---|
| Barre : hauteur 32 px, fond noir 92 %, filet bas de 1 px, police | `specs/barre` | ✅ |
| Barre : grandit au survol | demande | ✅ |
| Barre : icônes Hanko, bouton menu Moozy | Icônes de la barre | ✅ (Elsewhen, veilleuse, rappel : pas d'icône Hanko) |
| Barre : bureau actif en pastille accent, horloge en capitales | `specs/barre` | ✅ (espacement des lettres +8 % : non réglable) |
| Barre : ordre des widgets | Barre complète, dans ton ordre | ✅ (`hanko bar layout` ; Elsewhen, absent de la maquette, reste après la météo) |
| Widgets : horloge, date, météo, musique (1 écran) | `specs/widgets-bureau` | ✅ (musique non vérifiée : pas de lecteur dans la VM) |
| Widgets : rôles par écran (écran vertical : horloge, À FAIRE, jauges CPU/RAM/GPU/NET ; 4ᵉ écran : MOOZY) | `specs/widgets-bureau` | 🟡 horloge verticale codée, non vérifiée ; À FAIRE, jauges et 4ᵉ écran ⬜ |
| Fond différent par écran (05-papier-vertical sur le vertical, 04-moozy sur le 4ᵉ) | `specs/fond-par-ecran` | ⬜ |
| « EN DIRECT » Twitch (option) | `specs/twitch-en-direct` | ⬜ |
| Fenêtres : bordures 3 px crème/noir, angles droits, espaces, opacité, flou, animations | `looknfeel.md` | ✅ |

## Menus, notifications, OSD, sons
| Élément | Source | État |
|---|---|---|
| Menu et lanceur larges et bas, 6 lignes, couleurs | `specs/lanceur` · 11f | ✅ (icônes d'applis 28 px non vérifiées) |
| Notifications : carte crème, texte noir, en-tête de l'appli en accent foncé, bandeau critique 4 px, glissement d'entrée | `specs/notifications` | ✅ (`hanko ui`) |
| Son de notification | Sons | ✅ (`pw-play` lancé à chaque notification, sortie audio à 100 % ; non écouté) |
| Son de verrouillage | Sons | ✅ |
| Jauge volume / luminosité (OSD) | `specs/osd` · 11c | 🟡 `hanko ui` : fond noir, 8 % du bas, jauge 4 px sur fond #3a3330, accent (volume) / crème (luminosité) ✅ ; taille exacte 360 × 44, « MUET » et icône Hanko ⬜ |
| Capture d'écran / enregistrement : cadre accent 2 px, écran assombri | Ce qui pourrait encore suivre | ✅ (`hanko ui`, après reconnexion) |

## Verrouillage, veille, démarrage
| Élément | Source | État |
|---|---|---|
| Verrouillage : horloge Anton, date, champ déplacé, sans flou, secousse, son | `specs/verrouillage` | ✅ (un écran) |
| Verrouillage : titre HANKO + logo comme le bureau | demande | ✅ |
| Verrouillage : rôles par écran (vertical / horizontal) | `specs/verrouillage` | 🟡 codé, non vérifié (un seul écran dans la VM) |
| Veille : 11 animations | `specs/ecran-de-veille` | ✅ 10 vérifiées ; Vinyle ❔ (pas de lecteur) |
| Écran de déverrouillage du disque : couleurs, logo, champ | Démarrage | ✅ (vu au redémarrage) |
| Limine : couleurs du menu de démarrage | Démarrage · `boot/limine.conf` | ✅ (vu au redémarrage) |
| Logo « À propos » et fastfetch | about.txt | ✅ |

## Applications

À faire sur le PC principal (applications installées, deux écrans) : thèmes d'applis, rôles et fonds par écran, Twitch.

| Élément | Source | État |
|---|---|---|
| Spotify (Spicetify) | 11e · `apps-themes/spicetify` | ⬜ fichiers dans le thème, non installés |
| Discord (Vesktop) | 11e · `apps-themes/vesktop` | ⬜ fichiers dans le thème, non installés |
| Obsidian | 11e · `apps-themes/obsidian` | ⬜ fichiers dans le thème, non installés |
| Steam | 11e | ⬜ aucun fichier |
| Nautilus / applis GTK en sombre + Yaru-red | Ce qui pourrait encore suivre | 🟡 via Omarchy, non vérifié |

## Installation
| Élément | État |
|---|---|
| 3 niveaux : totale, essentiel, theme | ✅ (essentiel et theme non relancés de zéro) |
| `hanko update`, `doctor`, `uninstall`, `uninstall --all` | ✅ (`--all` non lancé) |
| Accroches système remises après les mises à jour d'Omarchy (hooks pacman) | ✅ installés ; jamais déclenchés par une vraie mise à jour |
| Fichiers tiers fournis + vérification hebdomadaire des versions et licences | ✅ |

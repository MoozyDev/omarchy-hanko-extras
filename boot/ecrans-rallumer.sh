#!/bin/sh
# Hanko — rallume les écrans éteints pendant le démarrage.
#
# `hanko boot ecran <sortie>` ajoute `video=<autre sortie>:d` à la ligne de
# commande du noyau pour chaque écran secondaire : l'écran de déverrouillage du
# disque (Plymouth) ne s'affiche alors que sur l'écran principal, au lieu d'être
# recopié sur tous les écrans sans tenir compte de leur rotation.
# Ce script, lancé par hanko-ecrans.service juste avant la session graphique,
# lit ces `video=…:d` et rend la main au noyau (« detect ») : les écrans
# reviennent et Hyprland les retrouve avec leur réglage habituel.
for arg in $(cat /proc/cmdline); do
  case $arg in
    video=*:d)
      out=${arg#video=}
      out=${out%:d}
      for status in /sys/class/drm/card*-"$out"/status; do
        [ -w "$status" ] && echo detect > "$status"
      done
      ;;
  esac
done
exit 0

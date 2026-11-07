#!/bin/bash
# Hanko for Omarchy 4 — one-command installer.
#
#   curl -fsSL https://raw.githubusercontent.com/MoozyDev/omarchy-hanko-extras/main/install.sh | bash -s vermillon
#
# Variants: vermillon (default), cramoisi, vert-billard.
# It clones this repo to ~/.local/share/hanko/extras, links the `hanko`
# command into ~/.local/bin, then runs `hanko install <variant>`.

set -euo pipefail

variant="${1:-vermillon}"
repo="${HANKO_REPO:-https://github.com/MoozyDev/omarchy-hanko-extras.git}"
home_dir="${HANKO_HOME:-$HOME/.local/share/hanko}"

[[ $EUID -ne 0 ]] || { echo "Lance l'installation en tant qu'utilisateur, pas en root." >&2; exit 1; }
command -v omarchy-shell >/dev/null 2>&1 || { echo "Hanko demande Omarchy 4 (omarchy-shell introuvable)." >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "git est requis." >&2; exit 1; }

mkdir -p "$home_dir" "$HOME/.local/bin"
if [[ -n ${HANKO_SOURCE:-} ]]; then
  # Development: install from a local copy instead of GitHub.
  [[ -f $HANKO_SOURCE/bin/hanko ]] || { echo "HANKO_SOURCE ne contient pas bin/hanko : $HANKO_SOURCE" >&2; exit 1; }
  rm -rf "$home_dir/extras"
  cp -r "$HANKO_SOURCE" "$home_dir/extras"
elif [[ -d $home_dir/extras/.git ]]; then
  git -C "$home_dir/extras" pull --ff-only --quiet
else
  rm -rf "$home_dir/extras"
  git clone --quiet --depth 1 -- "$repo" "$home_dir/extras"
fi
chmod +x "$home_dir/extras/bin/hanko"
ln -sfn "$home_dir/extras/bin/hanko" "$HOME/.local/bin/hanko"

# Read answers from the keyboard even though this script arrives on a pipe.
if [[ -r /dev/tty ]]; then
  exec "$home_dir/extras/bin/hanko" install "$variant" </dev/tty
else
  exec "$home_dir/extras/bin/hanko" install "$variant"
fi

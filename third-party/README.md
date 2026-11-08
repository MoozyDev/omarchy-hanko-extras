# Third-party files

Files made by other people, shipped here so `hanko` can install them in your home folder — no `sudo`, no AUR. Each one keeps its licence next to it. Versions are pinned in `VERSIONS`; a weekly GitHub Action (`.github/workflows/third-party.yml`) checks upstream for new releases and opens a pull request with the new archive and licence when there is one.

| Folder | What | Author | Licence | Version | Source |
|---|---|---|---|---|---|
| `bibata/` | Bibata Modern Classic cursor (`Bibata-Modern-Classic.tar.xz`, unmodified release archive) | Abdulkaiz Khatri (ful1e5) | GPL-3.0 — `bibata/LICENSE` | see `VERSIONS` | https://github.com/ful1e5/Bibata_Cursor (source of this exact version: its release tag) |
| `space-mono-nerd/` | Space Mono Nerd Font (`SpaceMono.tar.xz`, unmodified release archive) | Space Mono: Colophon Foundry · Nerd Fonts patch: Ryan L McIntyre and contributors | SIL OFL 1.1 — `space-mono-nerd/OFL.txt`; Nerd Fonts terms — `space-mono-nerd/NERD-FONTS-LICENSE` | see `VERSIONS` | https://github.com/ryanoasis/nerd-fonts |

Installed by `hanko`:
- cursor → `~/.local/share/icons/Bibata-Modern-Classic/`
- font (Regular, Bold, Italic, Bold Italic) → `~/.local/share/fonts/hanko/`

If the same font or cursor is already installed system-wide (`ttf-space-mono-nerd`, `bibata-cursor-theme-bin`), `hanko` uses that one and copies nothing.

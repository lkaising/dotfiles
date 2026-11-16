#!/usr/bin/env bash
# Link this repository's .bashrc into $HOME.
#
# VS Code's dotfiles feature runs this once, inside a new dev container,
# right after cloning the repository to ~/dotfiles.
set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_file="${dotfiles_dir}/.bashrc"
target_file="${HOME}/.bashrc"

# Keep the image's original ~/.bashrc once, in case it's ever needed.
if [ -f "$target_file" ] && [ ! -L "$target_file" ] && [ ! -e "${target_file}.orig" ]; then
    mv "$target_file" "${target_file}.orig"
    echo "dotfiles: saved original ${target_file} as ${target_file}.orig"
fi

ln -sfn "$source_file" "$target_file"
echo "dotfiles: linked ${target_file} -> ${source_file}"

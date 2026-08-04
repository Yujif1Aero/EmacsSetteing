#!/usr/bin/env bash
# Purge all dpkg-installed Emacs packages (emacs, emacs-gtk, emacs-mozc, ...).
# Note: this only REMOVES Emacs. To (re)install Emacs 30, run emacs_installer.sh
#       (its step [2/8] already purges before installing).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Collect installed packages named emacs / emacs-* / emacsen-common / emacs-mozc.
mapfile -t packages < <(
  dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\n' 2>/dev/null |
  awk '$1 ~ /^ii/ && ($2 ~ /^emacs([0-9]*)?(-|$)/ || $2 == "emacsen-common") {print $2}'
)

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No Emacs packages installed via dpkg. Nothing to purge."
  exit 0
fi

echo "Will purge:"
printf '  %s\n' "${packages[@]}"
sudo apt purge -y "${packages[@]}"
sudo apt autoremove --purge -y

echo "Remaining emacs-related packages (should be empty):"
dpkg -l | grep -Ei 'emacs|emacsen|elpa-' || echo "  (none)"

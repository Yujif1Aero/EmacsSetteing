#!/usr/bin/env bash
# Purge dpkg-installed Emacs EDITOR packages only (emacs, emacs-gtk, emacs-nox,
# emacs-common, emacs-bin-common, emacs-el, emacs-mozc, emacs-mozc-bin, ...).
#
# IMPORTANT: we deliberately DO NOT touch `emacsen-common`.
#   `dictionaries-common` depends on `emacsen-common`, so purging it cascades:
#   dictionaries-common -> enchant -> evolution-data-server/webkit -> gnome-shell
#   -> ubuntu-desktop -> gdm3.  Purging emacsen-common with `-y` once wiped the
#   whole GNOME desktop. Never again.
#
# To (re)install Emacs 30, run emacs_installer.sh (it calls this script first).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Collect installed emacs* editor packages, EXCLUDING the shared emacsen-common.
mapfile -t packages < <(
  dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\n' 2>/dev/null |
  awk '$1 ~ /^ii/ && $2 ~ /^emacs/ && $2 != "emacsen-common" {print $2}'
)

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No Emacs editor packages installed via dpkg. Nothing to purge."
  exit 0
fi

echo "Emacs packages to purge:"
printf '  %s\n' "${packages[@]}"

# SAFETY: simulate the purge and ABORT if it would drag in desktop/critical pkgs.
echo "Simulating removal to check for collateral damage..."
would_remove="$(apt-get -s purge "${packages[@]}" 2>/dev/null \
  | awk '/^(Remv|Purg) /{print $2}')"

danger="$(printf '%s\n' "${would_remove}" | grep -Ei \
  '^(ubuntu-desktop|ubuntu-desktop-minimal|ubuntu-session|gnome-shell|gnome-session|gdm3|gdm|kde-plasma-desktop|plasma-desktop|plasma-workspace|kwin-x11|kwin-wayland|sddm|lightdm|xfce4-session|dictionaries-common|emacsen-common)$' || true)"

if [[ -n "${danger}" ]]; then
  echo "ABORT: purging Emacs would also remove these critical packages:" >&2
  printf '  %s\n' ${danger} >&2
  echo "Refusing to proceed. Fix the package selection before purging." >&2
  exit 1
fi

echo "Safe to proceed. Purging Emacs..."
sudo apt purge -y "${packages[@]}"

echo "Remaining emacs editor packages (should be empty):"
dpkg -l | awk '/^ii/ && $2 ~ /^emacs/ && $2 != "emacsen-common" {print "  "$2}' \
  || echo "  (none)"

echo
echo "NOTE: not running 'apt autoremove --purge' automatically (it can also"
echo "      remove desktop libraries). If you want to clean orphans, review first:"
echo "      apt-get -s autoremove --purge   # simulate, then run without -s if safe"

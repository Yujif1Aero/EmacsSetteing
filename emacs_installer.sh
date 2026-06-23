#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[1/7] apt update & prerequisites"
sudo apt update
sudo apt install -y software-properties-common ca-certificates curl gnupg

echo "[2/7] remove currently installed Emacs packages (safe, exact list from dpkg)"
emacs_pkgs="$(dpkg -l | awk '/^ii/ && ($2 ~ /^emacs($|-)/ || $2 ~ /^emacsen-/) {print $2}')"
if [[ -n "${emacs_pkgs}" ]]; then
  echo "Will purge:"
  echo "${emacs_pkgs}"
  # shellcheck disable=SC2086
  echo "${emacs_pkgs}" | xargs -r sudo apt purge -y
else
  echo "No Emacs packages installed via dpkg."
fi

echo "[3/7] autoremove leftovers"
sudo apt autoremove --purge -y

echo "[4/7] disable/remove existing Emacs PPAs (if any)"
sudo rm -f /etc/apt/sources.list.d/*emacs*.list \
           /etc/apt/sources.list.d/*emacs*.sources || true

echo "[5/7] add Emacs 30.x PPA and update"
sudo add-apt-repository -y ppa:ubuntuhandbook1/emacs
sudo apt update

echo "[6/7] install Emacs + Mozc (fcitx) + emacs-mozc"
sudo apt install -y emacs
sudo apt install -y fcitx-mozc
sudo apt install -y mozc-server mozc-utils-gui mozc-data emacs-mozc

echo "[7/7] verify"
emacs --version | head -n 1
apt-cache policy emacs | sed -n '1,20p'

echo "Done."
echo "If you use a desktop session, you may need to log out/in for fcitx settings to take effect."

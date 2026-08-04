#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Resolve this script's directory so we can call the uninstaller regardless of cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/7] apt update & prerequisites"
sudo apt update
sudo apt install -y software-properties-common ca-certificates curl gnupg

echo "[2/7] remove currently installed Emacs (delegated to emacs_uninstaller.sh)"
# Purge is the uninstaller's responsibility; keep the logic in one place.
bash "${SCRIPT_DIR}/emacs_uninstaller.sh"

echo "[3/7] disable/remove existing Emacs PPAs (if any)"
sudo rm -f /etc/apt/sources.list.d/*emacs*.list \
           /etc/apt/sources.list.d/*emacs*.sources || true

echo "[4/7] add Emacs 30.x PPA and update"
sudo add-apt-repository -y ppa:ubuntuhandbook1/emacs
sudo apt update

echo "[5/7] install Emacs + Mozc (fcitx) + emacs-mozc"
sudo apt install -y emacs
sudo apt install -y fcitx-mozc
sudo apt install -y mozc-server mozc-utils-gui mozc-data
sudo apt install -y emacs-mozc emacs-mozc-bin

echo "[6/7] LaTeX toolchain + pdf-tools(epdfinfo) build deps (for AUCTeX/pdf-tools workflow)"
# latexmk = C-c C-c の既定コンパイラ, 残りは M-x pdf-tools-install で epdfinfo をビルドするのに必要
sudo apt install -y latexmk libpng-dev zlib1g-dev libpoppler-glib-dev libpoppler-private-dev
# 完全な LaTeX 環境が要る場合は texlive-full も（数GB, 必要なら手動で）:
#   sudo apt install -y texlive-full

echo "[7/7] verify"
emacs --version | head -n 1
apt-cache policy emacs | sed -n '1,20p'
command -v latexmk >/dev/null && echo "latexmk: $(latexmk -v | head -n1)" || echo "latexmk: NOT installed"

echo "Done."
echo "If you use a desktop session, you may need to log out/in for fcitx settings to take effect."

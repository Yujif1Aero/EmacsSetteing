#!/usr/bin/env bash
# Install ltex-ls-plus (LanguageTool LSP server, offline grammar/spell for LaTeX).
# Uses the linux-x64 build which BUNDLES a Java runtime -> no separate Java needed.
# Installed OUTSIDE this git repo (~/.local/opt) so the ~200MB payload is not tracked.
set -euo pipefail

VER="18.7.0"
DEST="$HOME/.local/opt"
DIR="$DEST/ltex-ls-plus-${VER}"
URL="https://github.com/ltex-plus/ltex-ls-plus/releases/download/${VER}/ltex-ls-plus-${VER}-linux-x64.tar.gz"

mkdir -p "$DEST"
if [[ -x "$DIR/bin/ltex-ls-plus" ]]; then
  echo ">> already installed: $DIR"
  exit 0
fi

echo ">> downloading ltex-ls-plus ${VER} (bundled Java, ~200MB)..."
tmp="$(mktemp -d)"
curl -fL -o "$tmp/ltex.tar.gz" "$URL"
echo ">> extracting to $DEST ..."
tar xzf "$tmp/ltex.tar.gz" -C "$DEST"
rm -rf "$tmp"

echo ">> done. Server binary:"
ls -l "$DIR/bin/"
echo ">> Emacs tex.el expects it at: $DIR/bin/ltex-ls-plus"

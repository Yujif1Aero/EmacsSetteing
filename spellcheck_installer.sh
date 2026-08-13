#!/usr/bin/env bash
# Reinstall English spell-check dictionaries (for Emacs flyspell/ispell).
set -e
echo ">> installing aspell + hunspell English dictionaries..."
sudo apt install -y aspell aspell-en hunspell-en-us wbritish hunspell-en-gb
echo ">> done. Check:"
aspell dump dicts | grep -E '^en' || true

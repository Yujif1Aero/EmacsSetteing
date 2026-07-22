#!/bin/bash
 dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\n' 2>/dev/null |
     awk '$1 ~ /^ii/ && ($2 ~ /^emacs/ || $2 == "emacsen-common" || $2 ~ /^elpa-/) {print $2}'
mapfile -t packages < <(
  dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\n' 2>/dev/null |
  awk '$1 ~ /^ii/ && $2 ~ /^emacs[0-9]*(-|$)/ {print $2}'
)

printf '%s\n' "${packages[@]}"
sudo apt purge "${packages[@]}"

dpkg -l | grep -Ei 'emacs|emacsen|elpa-'

sudo apt autoremove --purge

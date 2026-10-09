#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

if [[ ! -f $PLIST ]]; then
  echo "iTerm2 plist not found at $PLIST" >&2
  exit 1
fi

defaults read com.googlecode.iterm2 >/dev/null 2>&1 || true
cp "$PLIST" "$REPO_DIR/com.googlecode.iterm2.plist"
echo "Exported -> $REPO_DIR/com.googlecode.iterm2.plist"

# Dynamic profiles hold the color themes and are not part of the plist.
DYNAMIC_SRC="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
DYNAMIC_DST="$REPO_DIR/dynamic-profiles"
shopt -s nullglob
files=("$DYNAMIC_SRC"/*.json)
if (( ${#files[@]} )); then
  mkdir -p "$DYNAMIC_DST"
  cp "${files[@]}" "$DYNAMIC_DST"/
  echo "Exported -> $DYNAMIC_DST/"
fi

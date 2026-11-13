#!/usr/bin/env bash
# tmux-resurrect post-save hook: remove the kage session from the save just written.
# A restored empty kage session makes ~/kage/start.sh think Kage is running, so it never starts.
dir=$(tmux show -gqv @resurrect-dir)
dir=${dir:-$HOME/.local/share/tmux/resurrect}
dir=${dir/#\~/$HOME}
f=$(readlink -f "$dir/last") || exit 0
grep -vE $'^(pane|window)\tkage\t' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

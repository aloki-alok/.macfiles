#!/usr/bin/env bash
# Pick a tmux session: open sessions first, then zoxide folders. A folder opens (or reuses) a session named after it.
# Mirrors ThePrimeagen's tmux-sessionizer, with zoxide in place of a fixed folder list.
pick=$({ tmux list-sessions -F '#{session_name}'; zoxide query -l; } | fzf --reverse --no-sort --prompt='session > ') || exit 0
[ -n "$pick" ] || exit 0
if tmux has-session -t="$pick" 2>/dev/null; then
  tmux switch-client -t="$pick"
  exit 0
fi
name=$(basename "$pick" | tr '.:' '__')
tmux has-session -t="$name" 2>/dev/null || tmux new-session -ds "$name" -c "$pick"
tmux switch-client -t="$name"

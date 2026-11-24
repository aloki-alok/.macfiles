```text
Herdr or iTerm2 → zsh → tools
                    ╲ tmux → persistent terminal sessions
```

# Use the shell and tmux

The shell combines Starship, Atuin, fzf and zoxide. tmux remains available for persistent sessions. Herdr manages its own tabs and panes.

| Action | Command or key |
|---|---|
| Search shell history | Ctrl+R, through Atuin |
| Find a file | Ctrl+T, through fzf |
| Find a directory | Option+C, through fzf |
| Jump to a known directory | `cd <part-of-name>`, through zoxide |
| Browse files | `yazi` |
| Review git changes | `lg`, an alias for lazygit |
| Open Neovim | `v` |
| tmux session picker | Ctrl+B, then F |
| tmux git popup | Ctrl+B, then G |
| tmux splits | Ctrl+B, then vertical bar or minus |
| tmux windows | Option+1–5 |
| tmux pane focus | Option+H, J, K or L |

zsh startup loads Home Manager session variables before the prompt and tools. Machine-only aliases belong in `~/.zshrc.local`.

`direnv` and `nix-direnv` are enabled. A repository can declare its own development environment with `.envrc` and a flake. Review an `.envrc` before granting access.

tmux comes from Homebrew because its plugins use `/opt/homebrew/bin`. Its selected status style is `config/tmux/status/b-pills.conf`. The other saved styles remain available there.

Rectangle handles window placement through global Option shortcuts. Its installation and preferences live in `darwin.nix`, including launch at login and 8-point gaps.

| Action | Shortcut |
|---|---|
| Move window to the other display | Option+Return |
| Place in the left, bottom, top or right half | Option+H, J, K or L |
| Place in the left, center or right third | Option+1, 2 or 3 |
| Place in the left or right two thirds | Option+Shift+1 or 3 |
| Maximize | Option+F |
| Center | Option+C |
| Shrink or grow | Option+minus or equal |
| Restore previous size and position | Option+V |

When Rectangle runs, its global shortcuts take precedence over overlapping shell and tmux Option shortcuts above.

AeroSpace is installed with login startup disabled. JankyBorders is disabled. Their saved configuration remains in `config/aerospace.toml` and `home.nix`.

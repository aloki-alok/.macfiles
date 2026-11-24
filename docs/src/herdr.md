```text
Terminal mode: top tabs       Agents mode: numbered sidebar
             ╲               ╱
              shared terminals
```

# Use Herdr

Terminal mode shows task titles in the top bar. Agents mode shows those titles in the sidebar, grouped by status.

| Shortcut | Action |
|---|---|
| Cmd+Shift+L | Switch layout |
| Cmd+1–9 | Select the visible numbered agent in Agents mode, or a tab in Terminal mode |
| Cmd+[ or Cmd+] | Previous or next agent |
| Cmd+Shift+P | Command palette |
| Cmd+B | Toggle sidebar |
| Cmd+D or Cmd+Shift+D | Split right or down |
| Cmd+Shift+Enter | Zoom the pane |
| Cmd+Option+arrow | Focus a pane |

Appearance saves selections immediately. Kage, Kage Stack and Sakura have day and night palettes. Kawaii remains an alternative layout.

The complete bindings are in [keys.json](https://github.com/aloki-alok/.macfiles/blob/main/config/herdr/keys.json).

Edit personal panels, layouts and themes under `config/herdr`, then run `nh home switch`. Settings and keys apply through live links. The other files must remain writable copies because Herdr imports and file watchers depend on their location.

Fonts must be installed separately. The repo includes Anthrosevka Mono, Geist Pixel Square and Pixel Square Mono with their licenses. Other families come from `darwin.nix`. `AnthropicMonoWeb Nerd Font` stays machine-local. Herdr falls back to bundled JetBrains Mono when a family is missing.

Tokyo Night remains the theme for Neovim, Zed, iTerm2, bat, btop and shell colors. Herdr has its own palette selection.

Check a personal panel with `herdr-app check config/herdr/mods/<name>`. Activation preserves existing sessions and window state.

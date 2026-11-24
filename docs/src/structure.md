```text
.macfiles
├── flake.nix       inputs, outputs, checks, formatter
├── flake.lock      pinned Nix inputs
├── home.nix        user tools and configuration
├── darwin.nix      macOS settings and Homebrew
├── config/         plain app configuration
├── fonts/          custom fonts and licenses
└── docs/           this handbook
```

# Who owns each setting

This is one Mac with two configuration layers. Keep the root flat until another machine needs shared modules.

| Owner | Controls |
|---|---|
| Home Manager, `home.nix` | CLI tools, git, user files, fonts, activation tasks |
| nix-darwin, `darwin.nix` | Dock, keyboard, Finder, trackpad, Touch ID for sudo, Homebrew |
| Determinate Nix | Nix daemon and daemon settings |
| Apps | Sessions, caches, sign-ins and other runtime state |

`config/` holds zsh, Neovim, Zed, Herdr, tmux, Warp, iTerm2, Starship, Atuin, bat, btop and Firefox configuration. AeroSpace configuration remains saved with login startup disabled.

Most configuration uses live links. An app can therefore write an edit back into this repo. Herdr settings and keys use live links too. Its panels, themes and layouts use writable copies, deployed by Home Manager.

The complete package inventory is in [home.nix](https://github.com/aloki-alok/.macfiles/blob/main/home.nix) and [darwin.nix](https://github.com/aloki-alok/.macfiles/blob/main/darwin.nix). Those files remain the source of truth.

Private overrides live in `~/.zshrc.local`, `~/.gitconfig.local` and `~/.gitconfig-personal`. Kage credentials and session data stay outside this repo.

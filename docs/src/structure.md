# Who owns each setting

The configuration has two layers. Home Manager controls user tools and files. nix-darwin controls macOS preferences and Homebrew apps.

## Repository structure

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

## Configuration owners

| Owner | Controls |
|---|---|
| Home Manager, `home.nix` | CLI tools, git, user files, fonts, activation tasks |
| nix-darwin, `darwin.nix` | Dock, keyboard, Finder, trackpad, Touch ID for sudo, Homebrew |
| Determinate Nix | Nix daemon and daemon settings |
| Apps | Sessions, caches, sign-ins and other runtime state |

## App configuration

`config/` holds zsh, Neovim, Zed, Herdr, tmux, Warp, iTerm2, Starship, Atuin, bat, btop and Firefox configuration.

## Live links and writable copies

Most configuration uses live links. An app can therefore write an edit back into this repo. Herdr settings and keys use live links too. Its panels, themes and layouts use writable copies, deployed by Home Manager.

## Package inventories

The complete package inventory is in [home.nix](https://github.com/aloki-alok/.macfiles/blob/main/home.nix) and [darwin.nix](https://github.com/aloki-alok/.macfiles/blob/main/darwin.nix). Those files remain the source of truth.

## Private configuration

Private overrides live in `~/.zshrc.local`, `~/.gitconfig.local` and `~/.gitconfig-personal`. Kage credentials and session data stay outside this repo.

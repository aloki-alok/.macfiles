# macfiles

My MacBook setup. `install.sh` symlinks everything into `$HOME`.

```
.macfiles/
├── install.sh
├── zsh/
│   ├── zshrc       -> ~/.zshrc
│   └── prompt.zsh  -> ~/.config/zsh/prompt.zsh
├── scripts/
│   └── anime-motd.sh      -> ~/.config/scripts/anime-motd.sh
├── nvim/                  -> ~/.config/nvim
│   ├── init.lua           plugins, LSP, format-on-save, keymaps
│   ├── colors/noir.lua     the Noir colorscheme
│   └── lua/noir/           palette.lua (single source of the Noir colors)
├── iterm2/
│   ├── README.md          how to point iTerm2 here
│   └── export.sh          snapshot the current iTerm2 plist
├── vscode/
│   └── settings.json -> ~/Library/Application Support/Code/User/settings.json
├── firefox/               -> default Firefox profile (found via profiles.ini)
│   ├── user.js            prefs: forced black pages, larger fonts, no prefetch
│   └── chrome/            userChrome.css (black toolbar), userContent.css (fonts)
├── fonts/                 copied into ~/Library/Fonts on install
│   ├── AnthrosevkaMono-*.ttf
│   └── OFL.txt            SIL OFL 1.1 license for the fonts
└── bin/                   personal scripts, on PATH via zshrc
```

## Fresh machine

```sh
git clone <repo-url> ~/.macfiles
cd ~/.macfiles
./install.sh
```

Then open a new shell.

For iTerm2: see `iterm2/README.md`.

## Deps

`zinit` (bootstraps itself), `fzf`, `zoxide`, `atuin`, `direnv`, `eza`, `bat`, `fd`, `lazygit`, `yazi`, `nvim`, `bun`, `vivid`. Plus `nvm` if you want node (installed per its docs, not Homebrew). Most of them:

```sh
brew install fzf zoxide atuin direnv eza bat fd lazygit yazi neovim oven-sh/bun/bun vivid
brew install --cask iterm2
```

The prompt uses Nerd Font glyphs (` ❯ 󰔚 ✘ ⇡ ⇣`), so pick a Nerd-patched font in your terminal. `install.sh` ships `Anthrosevka Mono` (a custom Iosevka build, SIL OFL 1.1, from [nanxstats/anthrosevka](https://github.com/nanxstats/anthrosevka)) into `~/Library/Fonts`; it carries Nerd glyphs.

For Firefox: launch it once so it creates a profile, rerun `install.sh`, then restart Firefox. The CSS asks for `Anthropic Sans Web` and `AnthropicMonoWeb Nerd Font`. Those fonts aren't shipped here, so install them yourself or Firefox falls back to the system sans. The toolbar theme artwork is a normal add-on theme and isn't part of this.

## Theme

Noir, everywhere: iTerm2 (`iterm2/dynamic-profiles/noir.json`), VS Code
(`vscode/settings.json`, "Noir Dark"), and Neovim (`nvim/colors/noir.lua`).
`nvim/lua/noir/palette.lua` is the Neovim copy of the same palette.

---

Some of these files were yak-shaved alongside [Claude Code](https://claude.com/claude-code).

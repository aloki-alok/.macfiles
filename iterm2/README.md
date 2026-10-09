# iTerm2

## One-time setup: have iTerm2 read/write prefs here

1. Open iTerm2 -> Settings -> General -> Settings
2. Check **Load preferences from a custom folder or URL**
3. Point it at this directory: `~/.macfiles/iterm2`
4. Pick **Save changes to folder when iTerm2 quits**

From then on, every settings change you make is written to `com.googlecode.iterm2.plist` in this folder and can be committed.

## Manual export (if you don't want auto-save)

Run `./export.sh` after changing settings to snapshot the current plist into this folder.

## Restore on a new machine

1. Clone the dotfiles repo
2. Open iTerm2 -> Settings -> General -> Settings -> **Load preferences from a custom folder** -> select `~/.macfiles/iterm2`
3. Copy the themes into place: `cp ~/.macfiles/iterm2/dynamic-profiles/*.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/"`
4. Quit and reopen iTerm2

## What's tracked

- `com.googlecode.iterm2.plist` (the exported preferences)
- `dynamic-profiles/*.json` (the color themes: Amethyst, Midnight, Paper, Monochrome, Ember, Noir)

Caches and app-support state are gitignored.

Dynamic profiles are not inside the plist. iTerm2 keeps them in
`~/Library/Application Support/iTerm2/DynamicProfiles/`, so `export.sh` copies
that folder into `dynamic-profiles/` as well.

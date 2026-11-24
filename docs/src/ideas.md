```text
Daily friction → small trial → verify on this Mac → keep or remove
```

# Ideas worth trying

These are proposals, not installed additions. Maintenance was checked on 24 November 2026. Reliability still needs a trial on this Mac.

| Idea | Why it fits | Decision |
|---|---|---|
| [Rectangle](https://rectangleapp.com/) | Configurable keyboard snapping and screen regions | First window-tool trial. Keep native Spaces |
| [Moom](https://manytricks.com/moom/) | Saved app layouts, useful when reconnecting a display | Try if restoring whole layouts becomes a recurring task |
| A checked setup handbook | Searchable ownership, shortcuts, updates and recovery | Built in this repo |
| Per-project Nix environments | Each repo selects its own tools | Use the existing direnv integration first |
| [nix-index database](https://github.com/nix-community/nix-index-database) | Find which Nix package provides a missing command | Trial its macOS integration before replacing the shell handler |
| [Jujutsu](https://github.com/jj-vcs/jj) | Explore changes and rewrite history in a Git-backed repo | Isabel uses it. Trial separately and prove Kage Stack checks still run |
| CI for configuration changes | Catch a broken build before applying it | Add after choosing CI access and runners |
| Encrypted secret management | Restore private settings across machines | Consider when a second machine needs it |

[Isabel's dotfiles](https://github.com/isabelroses/dotfiles) inspired the documentation split and explicit ownership. Her [Mac window notes](https://github.com/isabelroses/dotfiles/blob/main/docs/src/content/docs/design/window-manager.md) say she usually uses no window manager on macOS.

Her documentation uses [Astro Starlight](https://github.com/isabelroses/dotfiles/blob/main/docs/astro.config.ts). This smaller handbook uses [mdBook](https://rust-lang.github.io/mdBook/), already packaged in our locked Nix input. It provides search and themes without adding a JavaScript dependency tree.

Her [Lethe](https://github.com/isabelroses/lethe) records Nix deployment history. Its README focuses on NixOS, and the repository metadata has no declared license. Verify licensing and macOS support before adopting it.

Her Linux desktop modules depend on Linux compositors and services. Their visual ideas can inform Herdr, but those modules do not replace macOS tools directly.

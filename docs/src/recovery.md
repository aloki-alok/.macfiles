```text
Broken change → identify owner → restore source → apply → verify
```

# Recover a working setup

1. Inspect the working tree and recent commits:

   ```sh
   git -C ~/.macfiles status --short
   git -C ~/.macfiles log -5 --oneline
   ```

2. Preserve unrelated edits before restoring a configuration file. Live links make a source edit visible immediately.
3. Restore the affected file from a known-good commit, then apply its owning layer.
4. Open the affected app and verify the original workflow.

| Failure | Recovery |
|---|---|
| Nix reports a new source file missing | Stage that file, then build again |
| A home activation broke | Inspect `home-manager generations`, then use `home-manager switch --rollback` |
| A system switch broke | Use `sudo darwin-rebuild switch --rollback` |
| A Herdr panel change broke | Restore its source in `config/herdr`, then run `nh home switch` |
| Firefox styling is absent | Open Firefox once, then run `nh home switch` |
| A font is missing | Check its cask or licensed file, then apply the owning layer |
| A Kage connection fails | Run `kage doctor` and follow the named fix |

A generation rollback does not restore live-linked files. It also does not reliably undo mutable app state, deployed Herdr copies or Homebrew updates. Restore those sources and apply them again.

Old Nix generations are collected weekly after 30 days. A generation is not a backup of credentials or app data.

Keep a separate machine backup for private overrides, signing keys, Kage state and the files you create. This repo alone cannot rebuild those.

```text
Markdown → locked mdBook → static HTML → local preview or static host
```

# Build and host this handbook

1. Edit the Markdown chapters in `docs/src`. Register a new chapter in `SUMMARY.md`.
2. Stage new files, then build:

   ```sh
   nix build ~/.macfiles#docs
   ```

3. Start the local preview:

   ```sh
   nix run ~/.macfiles#docs
   ```

4. Open the loopback address printed by the preview command. Check search, links, mobile width, and both color themes.
5. Stop the preview with Ctrl+C. Restart after source changes to build the new version.

The preview binds to the loopback interface. It starts no login service. The built files need no application server or database.

`nix flake check` builds the handbook alongside the Herdr checks. A missing chapter fails the build. Check links and rendered content when editing them.

The `result` link from `nix build` points to a deployable static site. A future host can serve that directory. For private access, configure authentication at the host or use an existing private network. No external host is configured here.

The source repo is public. Local hosting does not make committed content private. Keep the handbook safe to publish regardless of the final hosting choice.

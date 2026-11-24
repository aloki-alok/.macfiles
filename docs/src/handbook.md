```text
Markdown → locked mdBook → GitHub Actions → GitHub Pages
```

# Build and host this handbook

[Read the published handbook](https://aloki-alok.github.io/.macfiles/). Changes to the documentation, Nix build or publishing workflow on `main` trigger a build and deployment. Pull requests build the site without publishing it.

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

The `result` link from `nix build` points to the static site. `.github/workflows/docs.yml` builds that same package on Linux, uploads it, then deploys it through GitHub Pages. A failed build leaves the last successful deployment live.

The source repo and published handbook are public. Keep credentials and private machine state outside both.

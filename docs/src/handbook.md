```text
Markdown → locked mdBook → GitHub Actions → GitHub Pages
```

# Build and host this handbook

[Read the published handbook](https://aloki-alok.github.io/.macfiles/). Changes to the documentation, Nix build or publishing workflow on `main` trigger a build and deployment. Pull requests build the site without publishing it.

## Edit and build

1. Edit the Markdown chapters in `docs/src`. Register a new chapter in `SUMMARY.md`.
2. Stage new files, then build:

   ```sh
   nix build ~/.macfiles#docs
   ```

## Preview locally

1. Start the local preview:

   ```sh
   nix run ~/.macfiles#docs
   ```

2. Open the address printed by the command. Check search, links, mobile width, and both color themes.
3. Stop the preview with Ctrl+C. Restart after source changes to build the new version.

The preview binds to the loopback interface. It starts no login service. The built files need no application server or database.

## Publish the handbook

`nix flake check` builds the handbook alongside the Herdr checks. A missing chapter fails the build. Check links and rendered content when editing them.

The `result` link from `nix build` points to the static site. `.github/workflows/docs.yml` builds that same package on Linux, uploads it, then deploys it through GitHub Pages. A failed build leaves the last successful deployment live.

The source repo and published handbook are public. Keep credentials and private machine state outside both.

## Review the documentation preview

The [full documentation preview](https://aloki-alok.github.io/.macfiles/v/docs/) uses Astro Starlight. It includes the same source guides, grouped navigation, full-text search, page contents and copyable code.

`docs/site/prepare-docs.mjs` prepares the source Markdown for Starlight. The npm lockfile pins the site dependencies. Nix builds the site with an independently pinned dependency cache, then places it at `v/docs` in the Pages artifact.

The preview has `noindex` metadata while its design is under review. The existing handbook URLs remain available.

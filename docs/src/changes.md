```text
Edit → stage new files → check → build → review → switch
```

# Change and update the setup

1. Edit the owning file from [Who owns each setting](structure.md).
2. Stage new files so the flake can see them.
3. Format Nix and run the checks from the repo:

   ```sh
   nix fmt
   nix flake check
   ```

4. Build the layer you changed:

   ```sh
   nix build .#homeConfigurations.ryu.activationPackage
   nix build .#darwinConfigurations.maccy.system
   ```

5. Review the diff, then apply the changed layer:

   ```sh
   nh home switch
   sudo darwin-rebuild switch --flake ~/.macfiles#maccy
   ```

6. Verify the changed app and commit the configuration.

Add CLI packages to `home.packages` in `home.nix`. Add GUI apps and cask fonts to `homebrew.casks` in `darwin.nix`. Keep one installer per tool.

To update Nix packages, run this before the checks:

```sh
nix flake update --flake ~/.macfiles
```

Apply both layers when both changed. Homebrew apps, Herdr and zinit plugins have separate release lifecycles. A Nix lock update does not pin their versions.

Homebrew activation removes unlisted formulae, casks and taps. Review `darwin.nix` before any system switch.

`home.stateVersion` and `system.stateVersion` select compatibility defaults. Keep them unchanged during package updates.

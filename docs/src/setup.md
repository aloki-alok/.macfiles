```text
Nix → clone → machine choices → system → home → apps
```

# Set up a Mac

This flake targets Apple silicon, user `ryu`, and host `maccy`.

1. Install Nix using the [Determinate installer](https://docs.determinate.systems/):

   ```sh
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

2. Open a new terminal and clone the repo:

   ```sh
   git clone https://github.com/aloki-alok/.macfiles ~/.macfiles
   ```

3. Review the machine names in `home.nix`, `darwin.nix` and `flake.nix`. On a fresh Mac, remove the `ryu/kana-local` tap and replace its cask with `aloki-alok/tap/kana`. That local tap exists only on the original Mac.

4. Install Homebrew using its [official installation guide](https://docs.brew.sh/Installation). nix-darwin manages an existing Homebrew installation. It does not install Homebrew itself.

5. Apply the system layer using the locked input:

   ```sh
   sudo nix run --inputs-from ~/.macfiles nix-darwin -- switch --flake ~/.macfiles#maccy
   ```

6. Apply the home layer using the locked input:

   ```sh
   nix run --inputs-from ~/.macfiles home-manager -- switch --flake ~/.macfiles#ryu -b bak
   ```

7. Create `~/.gitconfig.local` with your email and signing key. Import the private signing key through your existing secure process.

8. Install Herdr through its [official installer](https://herdr.dev/download/), then open it. If you use Firefox, open it once and run `nh home switch` again.

`-b bak` preserves conflicting home files with a `.bak` suffix. If nix-darwin reports an existing `/etc` file, inspect and back up that named file before retrying.

See [Kage and Kage Stack](agents.md) for their separate setup instructions.

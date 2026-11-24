# Set up a Mac

Install the configuration on an Apple silicon Mac. The saved user is `ryu` and the saved hostname is `maccy`.

## Check the machine-specific settings

Review `home.nix`, `darwin.nix` and the output names in `flake.nix`. If the user or host differs, update all three before applying either layer.

On a fresh Mac, remove the `ryu/kana-local` tap and replace its cask with `aloki-alok/tap/kana`. The local tap exists only on the original Mac.

## Install the prerequisites

1. Install Nix using the [Determinate installer](https://docs.determinate.systems/):

   ```sh
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

2. Open a new terminal and clone the repo:

   ```sh
   git clone https://github.com/aloki-alok/.macfiles ~/.macfiles
   ```

3. Install Homebrew using its [official installation guide](https://docs.brew.sh/Installation). nix-darwin manages an existing Homebrew installation. It does not install Homebrew itself.

## Apply the system layer

Use the nix-darwin input pinned by this repo:

```sh
sudo nix run --inputs-from ~/.macfiles nix-darwin -- switch --flake ~/.macfiles#maccy
```

If nix-darwin reports an existing `/etc` file, inspect and back up that named file before retrying.

## Apply the home layer

Use the Home Manager input pinned by this repo:

```sh
nix run --inputs-from ~/.macfiles home-manager -- switch --flake ~/.macfiles#ryu -b bak
```

`-b bak` preserves conflicting home files with a `.bak` suffix.

## Connect the daily tools

1. Create `~/.gitconfig.local` with your email and signing key. Import the private signing key through your existing secure process.
2. Install Herdr through its [official installer](https://herdr.dev/download/), then open it.
3. If you use Firefox, open it once and run `nh home switch` again.
4. Follow [Kage and Kage Stack](agents.md) for their separate installations and private setup.

## Verify the configuration

From the repo, run:

```sh
nix flake check
```

Open a fresh terminal and check the changed apps. The checks build the documentation and test Herdr's panel logic. They do not validate private credentials or restore app sessions.

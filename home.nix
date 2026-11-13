{ config, pkgs, lib, ... }:
let
  repo = "${config.home.homeDirectory}/.macfiles";
  # Live link into config/: edits apply at once, no rebuild.
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/config/${path}";

  anthrosevka = pkgs.runCommand "anthrosevka-mono" { } ''
    mkdir -p $out/share/fonts/truetype
    cp ${./fonts}/*.ttf $out/share/fonts/truetype/
  '';

  itermProfiles = lib.mapAttrs' (name: _:
    lib.nameValuePair "Library/Application Support/iTerm2/DynamicProfiles/${name}" { source = link "iterm2/${name}"; }
  ) (builtins.readDir ./config/iterm2);
in
{
  home.username = "ryu";
  home.homeDirectory = "/Users/ryu";
  home.stateVersion = "25.11"; # never bump: it pins defaults, not package versions

  programs.home-manager.enable = true;

  # Find names at https://search.nixos.org/packages
  home.packages = with pkgs; [
    # files and search
    bat eza fd ripgrep
    # shell
    atuin fzf starship vivid zoxide
    # tools
    btop lazygit neovim tldr yazi
    anthrosevka
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # `use flake` in .envrc, cached
  };

  programs.nh = {
    enable = true;
    flake = repo; # lets `nh home switch` run from any folder
  };

  home.file = itermProfiles // {
    ".zshrc".source = link "zshrc";
    ".hushlogin".text = "";
    "Library/Application Support/Code/User/settings.json".source = link "vscode/settings.json";
    ".warp/settings.toml".source = link "warp/settings.toml";
    ".aerospace.toml".source = link "aerospace.toml";
  };

  xdg.configFile = {
    "nvim".source = link "nvim";
    "starship.toml".source = link "starship.toml";
  };

  # Firefox names its profile folder at random, so find it in profiles.ini.
  # A fresh Mac has no profile until Firefox runs once: switch again after that.
  home.activation.firefox = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ff="$HOME/Library/Application Support/Firefox"
    profile=$(${pkgs.gawk}/bin/awk -F= '/^\[Install/{i=1} i && /^Default=/{print $2; exit}' "$ff/profiles.ini" 2>/dev/null || true)
    if [ -n "$profile" ]; then
      run mkdir -p "$ff/$profile/chrome"
      run ln -sfn "${repo}/config/firefox/user.js" "$ff/$profile/user.js"
      run ln -sfn "${repo}/config/firefox/chrome/userChrome.css" "$ff/$profile/chrome/userChrome.css"
      run ln -sfn "${repo}/config/firefox/chrome/userContent.css" "$ff/$profile/chrome/userContent.css"
    fi
  '';
}

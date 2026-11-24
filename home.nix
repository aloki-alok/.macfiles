{
  config,
  pkgs,
  lib,
  ...
}:
let
  repo = "${config.home.homeDirectory}/.macfiles";
  # Live link into config/: edits apply at once, no rebuild.
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/config/${path}";

  personalFonts = pkgs.runCommand "personal-fonts" { } ''
    mkdir -p "$out/share/fonts/truetype" "$out/share/fonts/opentype"
    cp ${./fonts}/*.ttf "$out/share/fonts/truetype/"
    cp ${./fonts}/*.otf "$out/share/fonts/opentype/"
  '';

  itermProfiles = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "Library/Application Support/iTerm2/DynamicProfiles/${name}" {
      source = link "iterm2/${name}";
    }
  ) (builtins.readDir ./config/iterm2);

  herdrMods = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./config/herdr/mods)
  );

  herdrDefaults = pkgs.writeText "herdr-defaults.json" (
    builtins.toJSON {
      layout = "kage-agents";
      "workspace.panels" = [
        "files"
        "changes"
      ];
    }
  );
in
{
  home.username = "ryu";
  home.homeDirectory = "/Users/ryu";
  home.stateVersion = "25.11"; # never bump: it pins defaults, not package versions

  programs.home-manager.enable = true;

  # Find names at https://search.nixos.org/packages
  home.packages = with pkgs; [
    # files and search
    bat
    eza
    fd
    ripgrep
    # shell
    atuin
    fzf
    starship
    vivid
    zoxide
    # tools
    btop
    lazygit
    neovim
    tldr
    yazi
    fastfetch
    newsboat
    # languages and builds
    go
    rustc
    cargo
    pnpm
    gradle_9
    cmake
    meson
    automake
    uncrustify
    tree-sitter
    # git and release
    gh
    git-filter-repo
    act
    actionlint
    goreleaser
    python3Packages.twine
    # security scans
    gitleaks
    trufflehog
    semgrep
    osv-scanner
    # cloud and services
    awscli2
    cloudflared
    supabase-cli
    stripe-cli
    bitwarden-cli
    # network
    wget
    mtr
    speedtest-cli
    # media and documents
    imagemagick
    librsvg
    potrace
    fontforge
    pandoc
    poppler-utils
    yt-dlp
    whisper-cpp
    _7zz
    d2
    # macOS and devices
    duti
    scrcpy
    ideviceinstaller
    personalFonts
  ];
  # Still in Homebrew, on purpose: gnupg and pinentry-mac (gpg-agent.conf points
  # at the Homebrew path), tmux (its plugins expect /opt/homebrew/bin), the
  # podman and docker stack, postgresql@17 (data lives under Homebrew), mole
  # (nixpkgs has a different tool with that name), and tap-only formulae.

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # `use flake` in .envrc, cached
  };

  programs.nh = {
    enable = true;
    flake = repo; # lets `nh home switch` run from any folder
  };

  programs.git = {
    enable = true;
    signing = {
      format = "openpgp";
      # Plain gpg from PATH: a Nix gnupg would run a second gpg-agent on the same keyring.
      signer = "gpg";
      signByDefault = true; # the key itself lives in ~/.gitconfig.local
    };
    ignores = [
      ".DS_Store"
      ".vscode"
      "**/.claude/settings.local.json"
    ];
    # Email and signing key stay off this public repo. ~/projects/ repos use the personal identity.
    includes = [
      { path = "~/.gitconfig.local"; }
      {
        condition = "gitdir:~/projects/";
        path = "~/.gitconfig-personal";
      }
    ];
    settings = {
      user.name = "aloki-alok";
      # The empty helper clears any system default before gh takes over.
      credential."https://github.com".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
      credential."https://gist.github.com".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autostash = true;
      fetch.prune = true;
      rerere.enabled = true;
      core.hooksPath = "~/.config/kagestack/git-hooks";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "tokyonight_night";
    };
  };

  # Old generations pin every package they used, so the store only grows without this.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  home.file = itermProfiles // {
    ".zshrc".source = link "zshrc";
    ".hushlogin".text = "";
    ".warp/settings.toml".source = link "warp/settings.toml";
  };

  xdg.configFile = {
    "nvim".source = link "nvim";
    "starship.toml".source = link "starship.toml";
    "zed/settings.json".source = link "zed/settings.json";
    "tmux".source = link "tmux";
    "atuin/config.toml".source = link "atuin/config.toml";
    "bat/themes".source = link "bat/themes";
    "btop/btop.conf".source = link "btop/btop.conf";
    "herdr-app/settings.json".source = link "herdr/settings.json";
    "herdr-app/keys.json".source = link "herdr/keys.json";
  };

  home.activation.herdr = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.rsync}/bin/rsync -rltp --checksum --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
      --exclude=/mods --exclude=/settings.json --exclude=/keys.json \
      ${./config/herdr}/ "$HOME/.config/herdr-app/"
    ${lib.concatMapStringsSep "\n" (name: ''
      if [ -L "$HOME/.config/herdr-app/mods/${name}" ]; then
        errorEcho "Herdr panel ${name} must be a writable directory, not a link."
        exit 1
      fi
      run mkdir -p "$HOME/.config/herdr-app/mods/${name}"
      run ${pkgs.rsync}/bin/rsync -rltp --checksum --delete --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
        --exclude='*.d.ts' --exclude=jsconfig.json \
        ${./config/herdr/mods}/${name}/ "$HOME/.config/herdr-app/mods/${name}/"
    '') herdrMods}
    if [ ! -e "$HOME/.config/herdr-app/shared.json" ]; then
      run ${pkgs.coreutils}/bin/install -m 600 ${herdrDefaults} "$HOME/.config/herdr-app/shared.json"
    fi
  '';

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

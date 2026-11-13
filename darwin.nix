# System level: macOS settings and the apps Homebrew installs.
# Apply with: sudo darwin-rebuild switch --flake ~/.macfiles (the config is picked by hostname)
{ ... }:
{
  # Determinate Nix runs its own daemon and settings; nix-darwin must not fight it.
  nix.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "ryu";
  # Must match darwinConfigurations.maccy: darwin-rebuild picks the config by hostname.
  networking.hostName = "maccy";
  networking.computerName = "maccy";
  system.stateVersion = 6; # never bump: it pins defaults, not versions

  security.pam.services.sudo_local.touchIdAuth = true;

  # Values match what this Mac already had, so the first switch changes nothing.
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      tilesize = 58;
      show-recents = false;
      mineffect = "scale";
      expose-group-apps = true; # AeroSpace windows stay readable in Mission Control
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false; # key repeat instead of the accent popup, for vim keys
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      "com.apple.swipescrolldirection" = true;
    };
    finder.FXPreferredViewStyle = "Nlsv"; # list view
    trackpad = {
      Clicking = false;
      TrackpadThreeFingerDrag = false;
    };
  };

  homebrew = {
    enable = true;
    # A switch removes any formula, cask or tap not listed here, so `brew install` alone doesn't stick.
    onActivation.cleanup = "uninstall";
    taps = [
      # Local-only tap with a locally verified Kana build. A new Mac uses aloki-alok/tap/kana instead.
      "ryu/kana-local"
      "aloki-alok/tap"
      "nikitabobko/tap"
      "smudge/smudge"
      "stripe/stripe-cli"
      "theboredteam/boring-notch"
    ];
    brews = [
      "gnupg"
      "pinentry-mac"
      "tmux"
      "mole"
      "node"
      "ffmpeg"
      "postgresql@17"
      "python@3.11"
      "podman"
      "podman-compose"
      "docker"
      "docker-compose"
      "docker-credential-helper"
      "mcp-publisher"
      "tailscale"
      "smudge/smudge/nightlight"
    ];
    casks = [
      # work
      "zed" "google-chrome" "slack" "notion" "obsidian" "granola" "postman" "codex"
      "drawio" "excalidrawz" "ngrok" "gcloud-cli" "session-manager-plugin" "temurin"
      "android-commandlinetools" "android-platform-tools" "openmtp"
      # terminal
      "iterm2" "warp"
      # desktop
      "nikitabobko/tap/aerospace" "dockdoor" "maccy" "macpacker" "macshot" "monitorcontrol"
      "keyboardcleantool" "theboredteam/boring-notch/boring-notch" "tailscale-app"
      # chat and media
      "telegram" "whatsapp" "spotify"
      # own tools
      "aloki-alok/tap/mcpify" "aloki-alok/tap/mctop" "ryu/kana-local/kana-local"
      # fonts
      "font-jetbrains-mono" "font-jetbrains-mono-nerd-font" "font-0xproto-nerd-font"
      "font-atkinson-hyperlegible-mono" "font-blex-mono-nerd-font" "font-cascadia-mono-nf"
      "font-comic-mono" "font-comic-shanns-mono-nerd-font" "font-commit-mono-nerd-font"
      "font-departure-mono-nerd-font" "font-geist-mono" "font-google-sans-code"
      "font-hack-nerd-font" "font-ia-writer-mono" "font-ibm-plex-mono" "font-intel-one-mono"
      "font-iosevka" "font-maple-mono" "font-maple-mono-nf" "font-monaspace-nf"
      "font-recursive-code" "font-roboto-mono-nerd-font" "font-server-mono"
      "font-source-code-pro" "font-victor-mono-nerd-font" "font-zed-mono-nerd-font"
    ];
  };
}

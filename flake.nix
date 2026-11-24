{
  description = "Mac apps, tools and settings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Two layers: home-manager owns ~ (tools, dotfiles, no sudo), nix-darwin owns
  # the system (macOS settings, Homebrew apps, needs sudo).
  outputs = { nixpkgs, home-manager, nix-darwin, ... }:
  let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  in {
    homeConfigurations.ryu = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
    darwinConfigurations.maccy = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin.nix ];
    };

    checks.aarch64-darwin.herdr = pkgs.runCommand "herdr-config-check" {
      nativeBuildInputs = [ pkgs.nodejs ];
    } ''
      node --test ${./config/herdr}/tests/*.test.mjs
      touch "$out"
    '';
  };
}

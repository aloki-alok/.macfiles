{
  description = "Alok's MacBook Air";

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
  outputs = { nixpkgs, home-manager, nix-darwin, ... }: {
    homeConfigurations.ryu = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./home.nix ];
    };
    darwinConfigurations."Aloks-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin.nix ];
    };
  };
}

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
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      formatter.aarch64-darwin = pkgs.writeShellApplication {
        name = "macfiles-format";
        runtimeInputs = [ pkgs.nixfmt ];
        text = ''
          exec nixfmt flake.nix home.nix darwin.nix "$@"
        '';
      };

      packages = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ] (
        system:
        let
          docsPkgs = nixpkgs.legacyPackages.${system};
        in
        {
          docs-site = docsPkgs.buildNpmPackage {
            pname = "macfiles-docs-site";
            version = "1";
            src = ./docs;
            npmDepsHash = "sha256-WvaMJLcJ0xv6V2rp2564hYYBNpg7/0GAoqQ0A3lT+Yg=";
            npmFlags = [ "--ignore-scripts" ];
            ASTRO_TELEMETRY_DISABLED = "1";
            installPhase = ''
              mkdir -p "$out"
              cp -R dist/. "$out/"
            '';
          };

          docs = docsPkgs.stdenvNoCC.mkDerivation {
            pname = "macfiles-handbook";
            version = "1";
            src = ./docs;
            nativeBuildInputs = [ docsPkgs.mdbook ];
            buildPhase = "mdbook build";
            installPhase = ''
              mkdir -p "$out"
              cp -R book/. "$out/"
              mkdir -p "$out/v/docs"
              cp -R ${self.packages.${system}.docs-site}/. "$out/v/docs/"
              substituteInPlace "$out"/book-*.js \
                --replace-fail 'window.onunload = function() { };' ""
            '';
          };
        }
      );

      apps.aarch64-darwin.docs = {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            name = "macfiles-docs";
            runtimeInputs = [
              pkgs.python3
              pkgs.coreutils
            ];
            text = ''
              previewRoot=$(mktemp -d)
              trap 'rm -rf "$previewRoot"' EXIT
              ln -s ${self.packages.aarch64-darwin.docs} "$previewRoot/.macfiles"
              printf 'Open http://127.0.0.1:4178/.macfiles/\n'
              python3 -m http.server 4178 --bind 127.0.0.1 --directory "$previewRoot"
            '';
          }
        }/bin/macfiles-docs";
      };

      checks.aarch64-darwin.docs = self.packages.aarch64-darwin.docs;
      checks.x86_64-linux.docs = self.packages.x86_64-linux.docs;

      homeConfigurations.ryu = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
      darwinConfigurations.maccy = nix-darwin.lib.darwinSystem {
        modules = [ ./darwin.nix ];
      };

      checks.aarch64-darwin.herdr =
        pkgs.runCommand "herdr-config-check"
          {
            nativeBuildInputs = [ pkgs.nodejs ];
          }
          ''
            node --test ${./config/herdr}/tests/*.test.mjs
            touch "$out"
          '';
    };
}

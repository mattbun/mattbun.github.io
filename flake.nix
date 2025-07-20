{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };
  inputs.basix.url = "github:NotAShelf/Basix";

  outputs =
    { self, nixpkgs, flake-utils, basix, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        palette = basix.schemeData.base16."0x96f".palette;

        accent = palette.base09; # orange
        accent-hover = palette.base0E; # magenta
        bg = palette.base00;
        fg = palette.base07;

        colorsCss = /* css */ ''
          :root {
            --base00: ${palette.base00};
            --base01: ${palette.base01};
            --base02: ${palette.base02};
            --base03: ${palette.base03};
            --base04: ${palette.base04};
            --base05: ${palette.base05};
            --base06: ${palette.base06};
            --base07: ${palette.base07};
            --base08: ${palette.base08}; /* red */
            --base09: ${palette.base09}; /* orange */
            --base0A: ${palette.base0A}; /* yellow */
            --base0B: ${palette.base0B}; /* green */
            --base0C: ${palette.base0C}; /* cyan */
            --base0D: ${palette.base0D}; /* blue */
            --base0E: ${palette.base0E}; /* magenta */
            --base0F: ${palette.base0F}; /* brown */

            --main-bg-color: ${bg};
            --main-text-color: ${fg};
            --accent-color: ${accent};
            --accent-hover-color: ${accent-hover};
          }
        '';

        buildInputs = with pkgs; [
          bashInteractive
          git
          gnumake
          hugo
        ];

        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "mattbun.github.io";
          src = self;
          buildInputs = buildInputs;

          buildPhase = ''
            cp ${pkgs.writeText "colors.css" colorsCss} themes/dotfiles/assets/css/colors.css
            ${pkgs.hugo}/bin/hugo
          '';

          installPhase = "cp -r public $out";
        };

        packages.colors = pkgs.stdenv.mkDerivation {
          name = "mattbun.github.io/colors";
          src = self;
          buildInputs = buildInputs;

          buildPhase = ''
            cp ${pkgs.writeText "colors.css" colorsCss} colors.css
          '';

          installPhase = "cp colors.css $out";
        };

        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.hugo;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = buildInputs;
        };
      }
    );
}

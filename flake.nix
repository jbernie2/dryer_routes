{
  description = "ruby gem development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    ruby_gem_dev_shell = {
      url = "github:jbernie2/ruby_gem_dev_shell/main";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, ruby_gem_dev_shell }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [
        (final: prev: {
          ruby = final.ruby_3_1;
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; };

    in with pkgs;
      {
        devShells = rec {
          default = run;
          run = ( callPackage
            ruby_gem_dev_shell
            {
              project_root = ./.;
            }
          );
        };
      }
    );
}

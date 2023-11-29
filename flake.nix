{
  description = "ruby gem development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        dependencies = {
          ruby = import ./nix/ruby/setup.nix;
        };

        pkgOverlays = lib.lists.flatten (
          builtins.map 
            (d: d.packageOverlays)
            (lib.attrsets.attrValues dependencies)
        );
        pkgs = import nixpkgs { system = system; overlays = pkgOverlays; };
        lib = nixpkgs.lib;

        builds = lib.attrsets.mapAttrs (k: v: v.build lib pkgs) dependencies;

        buildInputs = lib.lists.flatten (
          builtins.map
            (b: lib.attrsets.attrValues b.outputs)
            (lib.attrsets.attrValues builds)
        );

        packages = lib.lists.flatten (
          ( builtins.map
            (b: b.packages )
            (lib.attrsets.attrValues builds)
          )
        );

      in
      {
        devShells = rec {
          default = run;
          run = pkgs.mkShell {
            buildInputs = buildInputs;
            packages = packages;
          };
        };

        packages = {
          default = builds.ruby.outputs.rubyEnv;
          updateDeps = builds.ruby.outputs.updateDeps;
          githubRelease = pkgs.callPackage ./nix/github/setup.nix {
            gemspec_path = ./dryer_routes.gemspec;
          };
          rubygemsRelease = pkgs.callPackage ./nix/rubygems_release {
            gemspec_path = ./dryer_routes.gemspec;
          };
        };
      }
    );
}

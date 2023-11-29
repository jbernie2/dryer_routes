{
  packageOverlays = [
    (final: prev: {
      ruby = final.ruby_3_0;
    })
  ];
  envOverrides = [];
  build = lib: pkgs:
    let
      outputs = rec {
        rubyEnv = pkgs.bundlerEnv {
          # The full app environment with dependencies
          name = "ruby-env";
          inherit (pkgs) ruby;
          gemdir = ../..; # Points to Gemfile.lock and gemset.nix
          extraConfigPaths = [../../dryer_factories.gemspec];
        };
        wrappedRuby = rubyEnv.wrappedRuby;
        updateDeps = pkgs.writeScriptBin "update-deps" (builtins.readFile
          (pkgs.substituteAll {
            src = ./scripts/update.sh;
            bundix = "${pkgs.bundix}/bin/bundix";
            bundler = "${rubyEnv.bundler}/bin/bundler";
          }));
      };
    in
    {
      outputs = outputs;
      packages = [];
      shellHook = ''
      '';
    };
}

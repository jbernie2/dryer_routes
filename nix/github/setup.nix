{ 
  gh,
  writeScriptBin,
  substituteAll,
  ruby,
  gemspec_path
}:
  writeScriptBin "release-gem" (builtins.readFile
    (substituteAll {
      src = ./scripts/release-gem.sh;
      gh = "${gh}/bin/gh";
      ruby = "${ruby}/bin/ruby";
      gemspec_path = gemspec_path;
    }))

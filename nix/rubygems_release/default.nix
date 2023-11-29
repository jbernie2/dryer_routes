{ 
  writeScriptBin,
  substituteAll,
  ruby,
  gemspec_path
}:
  writeScriptBin "rubygems-release" (builtins.readFile
    (substituteAll {
      src = ./scripts/release.sh;
      ruby = "${ruby}/bin/ruby";
      gem = "${ruby}/bin/gem";
      gemspec_path = gemspec_path;
    }))

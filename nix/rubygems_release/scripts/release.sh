#!@shell@

@gem@ build @gemspec_path@

gem_build_file=$(@ruby@ -e '
  require "rubygems"
  spec = Gem::Specification::load("@gemspec_path@")
  puts "#{spec.name}-#{spec.version}.gem"
')

@gem@ push $gem_build_file

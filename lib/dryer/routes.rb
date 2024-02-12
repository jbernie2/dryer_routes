require "zeitwerk"
require "rubygems"

module Dryer
  module Routes
    def self.version
      Gem::Specification::load(
        "./dryer_routes.gemspec"
      ).version
    end

    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dryer_routes"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dryer_routes.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/dryer_routes.rb",
        )
      end
    end
    loader.setup
  end
end

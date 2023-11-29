require_relative "./build_from_resource.rb"
module Dryer
  module Routes
    class Registry

      def initialize
        @resources = []
        @routes = []
      end

      def register(resource)
        @resources << resource
        @routes += BuildFromResource.call(resource)
        @routes
      end

      def to_rails_route_params
        @routes.map(&:to_rails_route_params)
      end

      attr_reader :routes, :resources

      private
      attr_writer :routes, :resources
    end
  end
end

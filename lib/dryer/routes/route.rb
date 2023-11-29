module Dryer
  module Routes
    class Route
      def initialize(route_config)
        @route_config = route_config
      end

      def to_rails_route_params
        []
      end

      private
      attr_reader :route_config
    end
  end
end


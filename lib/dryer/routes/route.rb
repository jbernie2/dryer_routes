module Dryer
  module Routes
    class Route
      def initialize(route_config)
        @route_config = route_config
      end

      def to_rails_route(router)
        router.send(
          route_config[:method],
          route_config[:url],
          to: "#{
            route_config[:controller].controller_path
            }##{
            route_config[:controller_action]
          }"
        )
      end

      def controller
        route_config[:controller]
      end

      def method
        route_config[:method]
      end

      def request_contract
        route_config[:request_contract]
      end

      def url_parameters_contract
        route_config[:url_parameters_contract]
      end

      def response_contract_for(status)
        route_config[:response_contracts][status]
      end

      def url(*args)
        if route_config[:url].is_a?(Proc)
          route_config[:url].call(*args)
        else
          route_config[:url]
        end
      end

      private
      attr_reader :route_config
    end
  end
end


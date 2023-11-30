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

      def to_rails_routes(router)
        @routes.map { |r| r.to_rails_route(router) }
      end

      def validate_request(request)
        route = @routes.filter do |r|
          r.controller == request.controller_class &&
          r.method == request.request_method_symbol
        end.first.then do |route|
          if route && route.request_contract
            route.request_contract.new.call(request.body).errors
          else
            []
          end
        end
      end

      def validate_response(controller:, method:, status:, body:)
        route = @routes.filter do |r|
          r.controller == controller &&
          r.method == method
        end.first.then do |route|
          if route && route.response_contract_for(status)
            route.response_contract_for(status).new.call(body).errors
          else
            []
          end
        end
      end

      attr_reader :routes, :resources

      private
      attr_writer :routes, :resources
    end
  end
end

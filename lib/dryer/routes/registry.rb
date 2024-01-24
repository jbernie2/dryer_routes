module Dryer
  module Routes
    class Registry

      def initialize
        @resources = []
        @routes = []
      end

      def register(*resources)
        resources = resources[0].is_a?(Array) ? resources[0] : resources
        validate_resources!(resources)
        @resources = resources
        @routes = resources.map do |r|
          BuildFromResource.call(r)
        end.flatten
        ResourceAccessors.call(object: self, resources: resources)
        @routes
      end

      def to_rails_routes(router)
        @routes.map { |r| r.to_rails_route(router) }
      end

      def validate_request(request)
        route_for(
          controller: request.controller_class,
          method: request.request_method_symbol
        ).then do |route|
          if route && route.request_contract
            route.request_contract.new.call(request.params).errors
          else
            []
          end
        end
      end

      def validate_response(controller:, method:, status:, body:)
        route_for(
          controller: controller.class,
          method: method.to_sym
        ).then do |route|
          if route && route.response_contract_for(status)
            route.response_contract_for(status).new.call(body).errors
          else
            []
          end
        end
      end

      def route_for(controller:, method:)
        @routes.filter do |r|
          r.controller == controller &&
            r.method == method
        end.first
      end

      def get_validated_values(request)
        route_for(
          controller: request.controller_class,
          method: request.request_method_symbol
        ).then do |route|
          ExtractValidatedKeys.call(
            payload: request.params,
            contract: route.request_contract
          )
        end
      end

      attr_reader :routes, :resources

      private
      attr_writer :routes, :resources

      def validate_resources!(resources)
        errors = resources.map do |r|
          ResourceSchema.new.call(r)
        end.select { |r| !r.errors.empty? }

        if !errors.empty?
          messages = errors.inject({}) do |messages, e|
            messages.merge(e.errors.to_h)
          end
          raise "Invalid arguments: #{messages}"
        end
      end
    end
  end
end

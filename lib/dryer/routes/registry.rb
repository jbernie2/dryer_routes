require_relative "./build_from_resource.rb"
require_relative "./hash_object.rb"
require_relative "./resource_schema.rb"

module Dryer
  module Routes
    class Registry

      def initialize
        @resources = []
        @routes = []
      end

      def register(*resources)
        validate_resources!(resources)
        @resources = resources
        @routes = resources.map do |r|
          BuildFromResource.call(r)
        end.flatten
        add_accessors_for_resources(resources)
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
          r.controller == controller
          r.method == method
        end.first
      end

      attr_reader :routes, :resources

      private
      attr_writer :routes, :resources

      def add_accessors_for_resources(resources)
        denormalize_resources(resources).inject(self) do |obj, (key, value)|
          obj.define_singleton_method(key) { HashObject.new(value) }
          obj
        end
      end

      def denormalize_resources(resources)
        resources.inject({}) do | h, resource |
          h[
            resource[:controller].controller_name.to_sym
          ] = denormalize_resource(resource)
          h
        end
      end

      def denormalize_resource(resource)
        resource[:actions].each do |key, value|
          resource[:actions][key][:url] =
            resource[:actions][key][:url] || resource[:url]
        end
        resource.merge(resource[:actions])
      end

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

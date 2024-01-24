require 'dryer_services'

module Dryer
  module Routes
    class ResourceAccessors < Dryer::Services::SimpleService
      
      def initialize(object:, resources:)
        @object = object
        @resources = resources
      end

      def call
        denormalize_resources(resources).inject(object) do |obj, (key, value)|
          obj.define_singleton_method(key) { HashObject.new(value) }
          obj
        end
      end

      private
      attr_reader :object, :resources

      def denormalize_resources(resources)
        resources.inject({}) do | h, resource|
          h[
            resource[:controller].controller_name.to_sym
          ] = denormalize_resource(resource)
          h
        end
      end

      def denormalize_resource(resource)
        resource[:actions].each do |key, value|
          resource[:actions][key][:url] = UrlBuilder.call(
            resource[:actions][key][:url] || resource[:url]
          )
        end
        resource.merge(resource[:actions])
      end
    end
  end
end

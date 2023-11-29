require_relative "./simple_service"

module Dryer
  module Routes
    class BuildFromResource < SimpleService
      def initialize(resource)
        @resource = resource
      end

      def call
        resource[:methods].map do |method, config|
          Route.new(
            controller: resource[:controller],
            url: resource[:url],
            method: method,
            controller_action: config[:controller_action],
            request_contract: config[:request_contract],
            response_contracts: config[:response_contracts]
          )
        end
      end

      attr_reader :resource
    end
  end
end

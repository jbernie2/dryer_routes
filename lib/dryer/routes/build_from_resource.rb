require "dryer_services"

module Dryer
  module Routes
    class BuildFromResource < Dryer::Services::SimpleService
      def initialize(resource)
        @resource = resource
      end

      def call
        resource[:actions].map do |action, config|
          Route.new(
            controller: resource[:controller],
            url: config[:url] || resource[:url],
            method: config[:method],
            controller_action: action,
            request_contract: config[:request_contract],
            response_contracts: config[:response_contracts]
          )
        end
      end

      attr_reader :resource
    end
  end
end

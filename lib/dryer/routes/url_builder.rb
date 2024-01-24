require "dryer_services"
require "debug"

module Dryer
  module Routes
    class UrlBuilder < Dryer::Services::SimpleService
      def initialize(url)
        @url = url
      end

      def call
        if contains_path_variables?
          url_function
        else
          url
        end
      end

      private
      attr_reader :url
      
      def path_variables
        @path_variables ||= url.match(/(:\w*)/)
      end

      def contains_path_variables?
        path_variables ? path_variables.length > 0  : false
      end

      def url_function
        -> (*args) do
          path_variables.to_a.zip(args).inject(url) do |path, (key, value)|
            if key && value
              path.sub(key.to_s, value.to_s)
            else
              path
            end
          end
        end
      end
    end
  end
end

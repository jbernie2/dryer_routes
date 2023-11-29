module Dryer
  module Routes
    class SimpleService
      def self.call(*args)
        if args.length == 1 && args[0].is_a?(Hash)
          new(**args[0]).call
        else
          new(*args).call
        end
      end
    end
  end
end

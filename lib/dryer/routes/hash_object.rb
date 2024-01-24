require 'dryer_services'

module Dryer
  module Routes
    class HashObject < Dryer::Services::SimpleService
      def initialize(hash)
        hash.each do |k,v|
          key = k.is_a?(Numeric) ? "_#{k}" : k

          if v.is_a?(Proc)
            self.send(:define_singleton_method, key, proc do |*args, **kwargs, &block|
              v.arity != 0 ? v.call(*args, **kwargs, &block) : v.call
            end)
          else
            self.instance_variable_set(
              "@#{key}", v.is_a?(Hash) ? HashObject.new(v) : v
            )

            self.send(
              :define_singleton_method, key, proc{self.instance_variable_get("@#{key}")}
            )
          end
        end
      end
    end
  end
end

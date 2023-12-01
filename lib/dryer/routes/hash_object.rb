module Dryer
  module Routes
    class HashObject
     def initialize(hash)
        hash.each do |k,v|
          key = k.is_a?(Numeric) ? "_#{k}" : k

          self.instance_variable_set(
            "@#{key}", v.is_a?(Hash) ? HashObject.new(v) : v
          )
          self.class.send(
            :define_method, key, proc{self.instance_variable_get("@#{key}")}
          )
        end
      end
    end
  end
end

require "dryer_services"

module Dryer
  module Routes
    class ExtractValidatedKeys < Dryer::Services::SimpleService
      def initialize(payload:, contract:)
        @payload = payload
        @contract = contract
      end

      def call
        return {} if payload == nil || contract == nil
        extract_keys(
          to_symbol_keys(payload),
          contract.send(:key_map)
        )
      end

      private 
      def extract_keys(payload, key_map)
        key_map.inject({}) do |validated_keys, key|
          validated_keys[key.name.to_sym] = if key.respond_to?(:members)
            extract_keys(payload[key.name.to_sym], key.members)
          else
            payload[key.name.to_sym]
          end
          validated_keys
        end
      end

      def to_symbol_keys(hash)
        hash.inject({}) do |sym_hash, (key, value)|
          sym_hash[key.to_sym] = if value.is_a?(Hash)
            to_symbol_keys(value)
          else
            value
          end
          sym_hash
        end
      end

      attr_reader :payload, :contract
    end
  end
end

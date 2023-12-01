require 'dry-validation'

module Dryer
  module Routes
    class ResourceSchema < Dry::Validation::Contract
      params do
        required(:controller).filled(:class)
        required(:url).filled(:string)
        required(:actions).filled(:hash)
      end

      class ActionSchema < Dry::Validation::Contract
        params do
          required(:method).filled(:symbol)
          optional(:request_contract)
          optional(:response_contracts).hash()
        end

        rule(:request_contract) do
          if value && !value.ancestors.include?(Dry::Validation::Contract)
            key.failure('must be a dry-validation contract')
          end
        end

        rule(:response_contracts) do
          values[:response_contracts].each do |key, value|
            if !value.ancestors.include?(Dry::Validation::Contract)
              key(:response_contracts).failure(
                'must be a dry-validation contract'
              )
            end
          end if values[:response_contracts]
        end
      end

      rule(:actions) do
        values[:actions].each do |key, value|
          res = ActionSchema.new.call(value)
          if !res.success?
            res.errors.to_h.each do |name, messages|
              messages.each do |msg|
                key([key_name, name]).failure(msg)
              end
            end
          end
        end
      end
    end
  end
end

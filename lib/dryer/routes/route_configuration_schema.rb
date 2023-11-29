module Dryer
  module Routes
    class RouteConfigurationSchema < Dry::Validation::Contract
      params do
        required(:controller).filled(:class)
        required(:url).filled(:string)
        required(:methods).hash do
          optional(:post).hash(MethodSchema)
          optional(:get).hash(MethodSchema)
          optional(:patch).hash(MethodSchema)
          optional(:put).hash(MethodSchema)
          optional(:delete).hash(MethodSchema)
        end
      end

      class MethodSchema < Dry::Validation::Contract
        params do
          required(:controller_action).filled(:string)
          required(:request_contract).filled(:class)
          required(:response_contrats).hash()
        end
      end
    end
  end
end
    #{
      #controller: UsersController,
      #url: "/users",
      #methods: {
        #post: {
          #controller_action: :create,
          #request_contract: Contracts::Users::Post::Request,
          #response_contracts: {
            #200 => Contracts::Users::Post::Responses::Created,
          #}
        #}
      #}
    #}

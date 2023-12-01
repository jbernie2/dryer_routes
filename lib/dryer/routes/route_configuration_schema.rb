module Dryer
  module Routes
    class RouteConfigurationSchema < Dry::Validation::Contract
      params do
        required(:controller).filled(:class)
        required(:url).filled(:string)
        required(:actions).hash do
          optional(:post).hash(ActionSchema)
        end
      end

      class MethodSchema < Dry::Validation::Contract
        params do
          required(:method).filled(:string)
          optional(:request_contract).filled(:class)
          optional(:response_contracts).hash()
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

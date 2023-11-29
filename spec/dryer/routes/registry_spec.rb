require_relative "../../../lib/dryer/routes/registry.rb"
require_relative "../../../lib/dryer/routes/route.rb"
require 'debug'

RSpec.describe Dryer::Routes::Registry do

  let(:resource) {
    {
      controller: UsersController,
      url: "/users",
      methods: {
        post: {
          controller_action: :create,
          request_contract: UserCreateRequestContract,
          response_contracts: {
            200 => UserCreateResponseContract,
          }
        },
        get: {
          controller_action: :create,
          response_contracts: {
            200 => UserGetResponseContract,
          }
        }
      }
    }
  }

  let(:rails_route_user_post_params) do
    {
    }
  end

  let(:rails_route_user_get_params) do
    {
    }
  end

  class UsersController
  end

  class UserCreateRequestContract
  end

  class UserCreateResponseContract
  end

  class UserGetResponseContract
  end

  describe "#register" do
    let(:registry) { described_class.new }

    it "stores the resources passed to it" do
      registry.register(resource)
      expect(
        registry.resources.length
      ).to eq(1)
    end

    it "converts resources to routes" do
      registry.register(resource)
      expect(
        registry.routes.length
      ).to eq(2)
    end
  end

  describe "#to_rails_route_params" do
    let(:registry) do
      described_class.new.tap{ |r| r.register(resource) }
    end
    it "can return the parameters for building a rails route" do
      expect(
        registry.to_rails_route_params
      ).to eq(
        [rails_route_user_post_params, rails_route_user_get_params]
      )
    end
  end

  describe "#validate_request" do
    let(:registry) { described_class.new.register_route(route) }

    it "can validate a request to a controller" do
      expect(
        registry.validate_request(
          controller_class,
          request
        )
      ).to eq(
        result
      )
    end
  end

  describe "#validate_response" do
    let(:registry) { described_class.new.register_route(route) }

    it "can validate a response from a controller" do
      expect(
        registry.validate_request(
          controller_class,
          response
        )
      ).to eq(
        result
      )
    end
  end
  #register_route(
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
  #)
  #end
end

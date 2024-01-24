require 'dry-validation'
require_relative "../lib/dryer_routes.rb"

RSpec.describe Dryer::Routes do
  RSpec.reset

  before do 
    stub_const("UsersController", Class.new do
      def self.controller_path
        "users"
      end

      def self.controller_name
        "users"
      end
    end)

    stub_const("UserCreateRequestContract", Class.new(Dry::Validation::Contract) do
      params do
        required(:foo).filled(:string)
      end
    end)

    stub_const("UserCreateResponseContract", Class.new(Dry::Validation::Contract) do
      params do
        required(:baz).filled(:string)
      end
    end)
    stub_const("Router", Class.new do
      def post(url, options = {})
        { method: :post, url: url, options: options}
      end

      def get(url, options = {})
        { method: :get, url: url, options: options}
      end

      def patch(url, options = {})
        { method: :patch, url: url, options: options}
      end
    end)
  end

  let(:router) { Router.new }
  let(:registry) { Dryer::Routes::Registry.new }
  it "returns the current gem version" do
    expect(
      registry.register({
        controller: UsersController,
        url: "/users",
        actions: {
          create: {
            url: "/users",
            method: :post,
            request_contract: UserCreateRequestContract,
            response_contracts: {
              200 => UserCreateResponseContract,
            }
          }
        }
      })
    ).to be_truthy

    expect(registry.to_rails_routes(router)).to be_truthy
  end
end

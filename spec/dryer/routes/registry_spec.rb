require_relative "../../../lib/dryer/routes/registry.rb"
require_relative "../../../lib/dryer/routes/route.rb"
require 'dry-validation'

RSpec.describe Dryer::Routes::Registry do

  let(:resources) {
    [
      {
        controller: UsersController,
        url: "/users/:id",
        actions: {
          create: {
            url: "/users",
            method: :post,
            request_contract: UserCreateRequestContract,
            response_contracts: {
              200 => UserCreateResponseContract,
            }
          },
          update: {
            method: :patch,
          },
          find: {
            method: :get,
            response_contracts: {
              200 => UserGetResponseContract,
            }
          }
        }
      },
      {
        controller: TagsController,
        url: "/tags",
        actions: {
          create: {
            method: :post,
            request_contract: TagCreateRequestContract,
            response_contracts: {
              201 => TagCreateResponseContract
            }
          }
        }
      }
    ]
  }

  let(:rails_route_user_post) do
    {
      method: :post,
      url: "/users",
      options: {
        to: "users#create"
      }
    }
  end

  let(:rails_route_user_get) do
    {
      method: :get,
      url: "/users/:id",
      options: {
        to: "users#find"
      }
    }
  end

  let(:rails_route_user_patch) do
    {
      method: :patch,
      url: "/users/:id",
      options: {
        to: "users#update"
      }
    }
  end

  let(:router) { Router.new }

  class Router
    def post(url, options = {})
      { method: :post, url: url, options: options}
    end

    def get(url, options = {})
      { method: :get, url: url, options: options}
    end

    def patch(url, options = {})
      { method: :patch, url: url, options: options}
    end
  end

  class Request
    def initialize(controller_class, request_method, params)
      @request_method_symbol = request_method.to_sym
      @params = params
      @controller_class = controller_class
    end

    attr_reader :controller_class, :params, :request_method_symbol
  end

  class UsersController
    def self.controller_path
      "users"
    end
    def self.controller_name
      "users"
    end
  end

  class TagsController
    def self.controller_path
      "tags"
    end
    def self.controller_name
      "tags"
    end
  end

  class UserCreateRequestContract < Dry::Validation::Contract
    params do
      required(:foo).filled(:string)
    end
  end

  class TagCreateRequestContract < Dry::Validation::Contract
    params do
      required(:name).filled(:string)
    end
  end

  class TagCreateResponseContract < Dry::Validation::Contract
    params do
    end
  end

  class UserCreateResponseContract < Dry::Validation::Contract
    params do
      required(:baz).filled(:string)
    end
  end

  class UserGetResponseContract < Dry::Validation::Contract
    params do
      required(:quux).filled(:string)
    end
  end

  describe "#register" do
    let(:registry) { described_class.new }

    it "stores the resources passed to it" do
      registry.register(resources)
      expect(
        registry.resources.length
      ).to eq(2)
    end

    it "converts resources to routes" do
      registry.register(resources)
      expect(
        registry.routes.length
      ).to eq(4)
    end

    it "accepts a single resource" do
      registry.register(resources.first)
      expect(
        registry.routes.length
      ).to eq(3)
    end

    it "accepts an array of resources" do
      registry.register(resources)
      expect(
        registry.routes.length
      ).to eq(4)
    end

    it "accepts multiple resources as individual arguments" do
      registry.register(*resources)
      expect(
        registry.routes.length
      ).to eq(4)
    end
  end

  describe "#to_rails_routes" do
    let(:registry) do
      described_class.new.tap{ |r| r.register(resources) }
    end
    it "can return the parameters for building a rails route" do
      expect(
        registry.to_rails_routes(router)
      ).to include(
        rails_route_user_post, rails_route_user_get, rails_route_user_patch
      )
    end
  end

  describe "#validate_request" do
    let(:registry) do
      described_class.new.tap{ |r| r.register(resources) }
    end

    context "when the payload is valid" do
      let(:request) { Request.new(UsersController, :post, { foo: 'bar' }) }
      it "returns no errors" do
        expect(
          registry.validate_request(request)
        ).to be_empty
      end
    end

    context "when the payload is valid" do
      let(:request) { Request.new(TagsController, :post, { name: 'bar' }) }
      it "returns no errors" do
        expect(
          registry.validate_request(request)
        ).to be_empty
      end
    end

    context "when the payload is invalid" do
      let(:request) { Request.new(UsersController, :post, { bar: 'baz' }) }
      it "returns the errors" do
        expect(
          registry.validate_request(
            request
          )
        ).to_not be_empty
      end
    end

    context "when there is no matching route" do
      let(:request) { Request.new(UsersController, :poop, { bar: 'baz' }) }
      it "returns the errors" do
        expect(
          registry.validate_request(
            request
          )
        ).to be_empty
      end
    end

    context "when there is no contract defined" do
      let(:request) { Request.new(UsersController, :patch, { bar: 'baz' }) }
      it "returns the errors" do
        expect(
          registry.validate_request(
            request
          )
        ).to be_empty
      end
    end
  end

  describe "#validate_response" do
    let(:registry) do
      described_class.new.tap{ |r| r.register(resources) }
    end

    context "when the payload is valid" do
      let(:response) do
        {
          controller: UsersController.new,
          method: :get,
          status: 200,
          body: { quux: 'bar' }
        }
      end

      it "returns no errors" do
        expect(
          registry.validate_response(**response)
        ).to be_empty
      end
    end

    context "when the payload is invalid" do
      let(:response) do
        {
          controller: UsersController.new,
          method: :get,
          status: 200,
          body: { bar: 'baz' }
        }
      end

      it "returns the errors" do
        expect(
          registry.validate_response(**response)
        ).to_not be_empty
      end
    end

    context "when there is no contract for the return status" do
      let(:response) do
        {
          controller: UsersController.new,
          method: :get,
          status: 999,
          body: { literally: "anything" }
        }
      end

      it "returns no errors" do
        expect(
          registry.validate_response(**response)
        ).to be_empty
      end
    end

    context "when there is no matching route" do
      let(:response) do
        {
          controller: Object,
          method: :poop,
          status: 999,
          body: { literally: "anything" }
        }
      end

      it "returns no errors" do
        expect(
          registry.validate_response(**response)
        ).to be_empty
      end
    end
  end

  it "create a class for each route" do
    registry = described_class.new.tap{ |r| r.register(resources) }
    expect(
      registry.users.create
    ).to be_truthy
    expect(
      registry.users.create.request_contract
    ).to eq(UserCreateRequestContract)
    expect(
      registry.users.create.url
    ).to eq("/users")
    expect(
      registry.users.create.response_contracts._200
    ).to eq(UserCreateResponseContract)
  end

  context "when the http method is missing" do
    let(:resources) do
      {
        controller: UsersController,
        url: "/users/:id",
        actions: {
          create: {
            url: "/users",
            request_contract: UserCreateRequestContract,
            response_contracts: {
              200 => UserCreateResponseContract,
            }
          }
        }
      }
    end

    it " raises an error" do
      expect { described_class.new.register(resources) }.to raise_error(
        RuntimeError,
        /Invalid arguments: {:actions=>{:method=>\["is missing"\]}}/
      )
    end
  end

  context "when request_contract is not a contract" do
    let(:resources) do
      {
        controller: UsersController,
        url: "/users/:id",
        actions: {
          create: {
            url: "/users",
            method: :post,
            request_contract: Object,
            response_contracts: {
              200 => UserCreateResponseContract,
            }
          }
        }
      }
    end

    it " raises an error" do
      expect { described_class.new.register(resources) }.to raise_error(
        RuntimeError,
        /Invalid arguments: {:actions=>{:request_contract=>\["must be a dry-validation contract"\]}}/
      )
    end
  end

  context "when response_contracts are not contracts" do
    let(:resources) do
      {
        controller: UsersController,
        url: "/users/:id",
        actions: {
          create: {
            url: "/users",
            method: :post,
            request_contract: UserCreateRequestContract,
            response_contracts: {
              200 => Object,
            }
          }
        }
      }
    end

    it " raises an error" do
      expect { described_class.new.register(resources) }.to raise_error(
        RuntimeError,
        /Invalid arguments: {:actions=>{:response_contracts=>\["must be a dry-validation contract"\]}}/
      )
    end
  end
end

require_relative "../../../lib/dryer/routes/registry.rb"
require_relative "../../../lib/dryer/routes/route.rb"
require 'dry-validation'

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
        patch: {
          controller_action: :update,
        },
        get: {
          controller_action: :find,
          response_contracts: {
            200 => UserGetResponseContract,
          }
        }
      }
    }
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
      url: "/users",
      options: {
        to: "users#find"
      }
    }
  end

  let(:rails_route_user_patch) do
    {
      method: :patch,
      url: "/users",
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
    def initialize(request_method, body)
      @request_method_symbol = request_method.to_sym
      @body = body
    end
    attr_reader :body, :request_method_symbol
    def controller_class
      UsersController
    end
  end

  class UsersController
    def self.controller_path
      "users"
    end
  end

  class UserCreateRequestContract < Dry::Validation::Contract
    params do
      required(:foo).filled(:string)
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
      registry.register(resource)
      expect(
        registry.resources.length
      ).to eq(1)
    end

    it "converts resources to routes" do
      registry.register(resource)
      expect(
        registry.routes.length
      ).to eq(3)
    end
  end

  describe "#to_rails_routes" do
    let(:registry) do
      described_class.new.tap{ |r| r.register(resource) }
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
      described_class.new.tap{ |r| r.register(resource) }
    end

    context "when the payload is valid" do
      let(:request) { Request.new(:post, { foo: 'bar' }) }
      it "returns no errors" do
        expect(
          registry.validate_request(request)
        ).to be_empty
      end
    end

    context "when the payload is invalid" do
      let(:request) { Request.new(:post, { bar: 'baz' }) }
      it "returns the errors" do
        expect(
          registry.validate_request(
            request
          )
        ).to_not be_empty
      end
    end

    context "when there is no matching route" do
      let(:request) { Request.new(:poop, { bar: 'baz' }) }
      it "returns the errors" do
        expect(
          registry.validate_request(
            request
          )
        ).to be_empty
      end
    end

    context "when there is no contract defined" do
      let(:request) { Request.new(:patch, { bar: 'baz' }) }
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
      described_class.new.tap{ |r| r.register(resource) }
    end

    context "when the payload is valid" do
      let(:response) do
        {
          controller: UsersController,
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
          controller: UsersController,
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
          controller: UsersController,
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
end

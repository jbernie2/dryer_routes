# Dryer Routes
Dryer Routes is a gem allows for request and response types to be added to a
Rails routes file via [dry-validation](https://dry-rb.org/gems/dry-validation/1.8/) contracts

## Installation
add the following to you gemfile
```
gem "dryer_routes"
```

## Usage
Add this code to `config/initializers/dry_routes.rb`
```
RouteRegistry = Dryer::Routes::Registry.new
```

And then in `config/routes.rb` you can register your app's routes, eg.
```
Rails.application.routes.draw do
  RouteRegistry.register(
    {
      controller: UsersController,
      url: "/users",
      actions: {
        create: {
          method: :post,
          request_contract: Contracts::Users::Post::Request,
          response_contracts: {
            200 => Contracts::Users::Post::Response,
          }
        }
      }
    },
    {
      controller: SessionsController,
      url: "/sessions",
      actions: {
        create: {
          method: :post,
          request_contract: Contracts::Sessions::Post::Request,
          response_contracts: {
            200 => Contracts::Sessions::Post::Response,
          }
        }
      }
    }
  )
  RouteRegistry.to_rails_routes(self)
end
```

## Features
This gem helps organize and enforce typing for your routes, all relevant data
can be accessed through the gem keeping your code *dry*

### Easy to find route metadata
request contracts: `RouteRegistry.users.create.request_contract`

route url: `RouteRegistry.users.create.url`

response contracts: `RouteRegistry.users.create.response_contracts._200`

### Generating types in controller tests
```
class UsersControllerIntegreationTest < ActionDispatch::IntegrationTest
  test "POST 200 - successfully creating a user" do
    request = Dryer::Factories::BuildFromContract.call(
      RouteRegistry.users.create.request_contract
    )
    post RouteRegistry.users.create.url, params: request.as_json

    assert_response :success

    assert_empty RouteRegistry.users.create.response_contracts._200.new.call(
      JSON.parse(response.body)
    ).errors
  end
end
```
Shameless plug for my other gem [dryer_factories](https://github.com/jbernie2/dryer-factories)

### Enforcing types in Controllers
By adding an `around_action` to `ApplicationController`, a controller's requests
and responses can be validated automatically eg:
```
class ApplicationController < ActionController::Base
  include Dry::Monads[:result]

  around_action :validate_request_and_response

  def validate_request
    request_errors = RouteRegistry.validate_request(request)
    if request_errors.empty?
      @validated_request_body = Dry::Monads::Success(request.params)
    else
      @validated_request_body = Dry::Monads::Failure(request_errors)
    end
  end
  attr_reader :validated_request_body

  def validate_response
    response_errors = RouteRegistry.validate_response(
      controller: request.controller_class,
      method: request.request_method_symbol,
      status: response.status,
      body: JSON.parse(response.body)
    )
    if !response_errors.empty?
      Rails.logger.error("
        #{request.controller_class}##{request.request_method_symbol}
        response errors: #{response_errors}
      ")
    end
    response
  end

  def validate_request_and_response
    validate_request
    if validated_request_body.success?
      yield
      validate_response
    else
      render json: {errors: validated_request_body.failure.to_h}, status: :bad_request
    end
  end
end
```

Allowing the controller to look like
```
class UsersController < ApplicationController
  def create
    validated_request_body.bind do |body|
      # Do stuff
    end
  end
end
```

## Development
This gem is set up to be developed using [Nix](https://nixos.org/) and
[ruby_gem_dev_shell](https://github.com/jbernie2/ruby_gem_dev_shell)
Once you have nix installed you can run `make env` to enter the development
environment and then `make` to see the list of available commands

## Contributing
Please create a github issue to report any problems using the Gem.
Thanks for your help in making testing easier for everyone!

## Versioning
Dryer Routes follows Semantic Versioning 2.0 as defined at https://semver.org.

## License
This code is free to use under the terms of the MIT license.

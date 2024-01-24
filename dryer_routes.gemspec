Gem::Specification.new do |spec|
  spec.name                  = 'dryer_routes'
  spec.version               = "0.5.3"
  spec.authors               = ['John Bernier']
  spec.email                 = ['john.b.bernier@gmail.com']
  spec.summary               = 'Typed routing for rails leveraging dry-validation contracts'
  spec.description           = <<~DOC
    An extension of the Dry family of gems (dry-rb.org).
    This gem allows for rails routes to specify contracts for requests 
    and responses
  DOC
  spec.homepage              = 'https://github.com/jbernie2/dryer-routes'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 3.0.0'
  spec.files = Dir[
    'README.md',
    'LICENSE',
    'CHANGELOG.md',
    'lib/**/*.rb',
    'dryer_routes.gemspec',
    '.github/*.md',
    'Gemfile'
  ]
  spec.add_dependency "dry-validation", "~> 1.10"
  spec.add_dependency "dry-types", "~> 1.7"
  spec.add_dependency "dryer_services", "~> 2.0"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "debug", "~> 1.8"
end

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rails_param/version'

Gem::Specification.new do |s|
  s.name        = 'rails_param'
  s.version     = RailsParam::VERSION
  s.authors     = ["Nicolas Blanco"]
  s.email       = 'nicolas@nicolasblanco.fr'
  s.homepage    = 'http://github.com/nicolasblanco/rails_param'
  s.license     = 'WTFPL'

  s.description = %q{
    Parameter Validation & Type Coercion for Rails
  }

  s.summary = 'Parameter Validation & Type Coercion for Rails'

  s.required_rubygems_version = '>= 1.3.6'

  s.files = Dir.glob("lib/**/*.rb") + %w(README.md)

  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.11'
  s.add_development_dependency 'rspec-rails', '~> 2.11'
  s.add_development_dependency 'actionpack', '>= 4.1.0'
  s.add_development_dependency 'activesupport', '>= 4.1.0'
end

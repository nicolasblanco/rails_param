require 'active_support/all'
require 'action_controller'
require 'action_dispatch'
require 'rails'
require 'rails_param'

# Boilerplate
module Rails
  class App
    def env_config; {} end
    def routes
      return @routes if defined?(@routes)
      @routes = ActionDispatch::Routing::RouteSet.new
      @routes.draw do
        get '/fake/new' => "fake#new"
        get '/fakes' => "fake#index"
        get '/fake/(:id)' => "fake#show"
        get '/fake/edit' => "fake#edit"
        get '/fake/nested_array' => "fake#nested_array"
        get '/fake/nested_array_optional_element' => "fake#nested_array_optional_element"
        get '/fake/nested_array_required_element' => "fake#nested_array_required_element"
        post '/fake/array' => "fake#array"
        post '/fake/array' => "fake#array_optional_element"
        post '/fake/array' => "fake#array_required_element"
      end
      @routes
    end
  end
  def self.application
    @app ||= App.new
  end
end

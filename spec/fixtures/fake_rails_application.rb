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
      end
      @routes
    end
  end
  def self.application
    @app ||= App.new
  end
end

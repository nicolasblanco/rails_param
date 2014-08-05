require 'fixtures/fake_rails_application'

class FakeController < ActionController::Base
  include Rails.application.routes.url_helpers

  def show
    render text: "Foo"
  end

  def index
    param! :sort, String, in: %w(asc desc), default: "asc", transform: :downcase
    param! :page, Integer, default: 1

    render text: "index"
  end

  def new
    render text: "new"
  end
end

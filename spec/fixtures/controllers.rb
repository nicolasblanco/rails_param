require 'fixtures/fake_rails_application'

class FakeController < ActionController::Base
  include Rails.application.routes.url_helpers

  def show
    render plain: "Foo"
  end

  def index
    param! :sort, String, in: %w(asc desc), default: "asc", transform: :downcase
    param! :page, Integer, default: 1

    render plain: "index"
  end

  def new
    render plain: "new"
  end

  def edit
    param! :book, Hash, required: true do |b|
      b.param! :title, String, required: true
      b.param! :author, Hash do |a|
        a.param! :first_name, String, required: true
        a.param! :last_name, String, required: true
        a.param! :age, Integer, required: true
      end
      b.param! :price, BigDecimal, required: true
    end
    render plain: :book
  end

end

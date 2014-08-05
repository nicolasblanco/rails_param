require 'fixtures/controllers'
require 'rspec/rails'

describe FakeController, type: :controller do
  describe "type coercion" do
    it "coerces to integer" do
      get :index, page: "666"

      expect(controller.params[:page]).to eql(666)
    end
  end

  describe ":raise parameter" do
    it "raises an exception if set" do
      expect { get :index, sort: "foo" }.to raise_error(RailsParam::Param::InvalidParameterError)
    end
  end

  describe ":transform parameter" do
    it "applies transformations" do
      get :index, sort: "ASC"

      expect(controller.params[:sort]).to eql("asc")
    end
  end

  describe "default values" do
    it "applies default values" do
      get :index

      expect(controller.params[:page]).to eql(1)
      expect(controller.params[:sort]).to eql("asc")
    end
  end
end

require 'fixtures/controllers'
require 'rspec/rails'

describe FakeController, type: :controller do
  describe "type coercion" do
    it "coerces to integer" do
      get :index, page: "666"

      expect(controller.params[:page]).to eql(666)
    end
  end

  describe "nested_hash" do
    it "validates nested properties" do
      params = {
        'book' => {
          'title' => 'One Hundred Years of Solitude',
          'author' => {
            'first_name' => 'Garbriel Garcia',
            'last_name' => 'Marquez',
            'age' => '70'
          },
          'price' => '$1,000.00'
        }}
      get :edit, params
      expect(controller.params[:book][:author][:age]).to eql 70
      expect(controller.params[:book][:author][:age]).to be_kind_of Integer
      expect(controller.params[:book][:price]).to eql 1000.0
      expect(controller.params[:book][:price]).to be_instance_of BigDecimal
    end

    it "raises error when required nested attribute missing" do
      params = {
        'book' => {
          'title' => 'One Hundred Years of Solitude',
          'author' => {
            'last_name' => 'Marquez',
            'age' => '70'
          },
          'price' => '$1,000.00'
        }}
      expect { get :edit, params }.to raise_error { |error|
        expect(error).to be_a(RailsParam::Param::InvalidParameterError)
        expect(error.param).to eql("first_name")
        expect(error.options).to eql({:required => true})
      }
    end

    it "passes when hash that's not required but has required attributes is missing" do
      params = {
        'book' => {
          'title' => 'One Hundred Years of Solitude',
          'price' => '$1,000.00'
        }}
      get :edit, params
      expect(controller.params[:book][:price]).to eql 1000.0
      expect(controller.params[:book][:price]).to be_instance_of BigDecimal
    end
  end

  describe "InvalidParameterError" do
    it "raises an exception with params attributes" do
      expect { get :index, sort: "foo" }.to raise_error { |error|
        expect(error).to be_a(RailsParam::Param::InvalidParameterError)
        expect(error.param).to eql("sort")
        expect(error.options).to eql({:in => ["asc", "desc"], :default => "asc", :transform => :downcase})
      }
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

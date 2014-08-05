require 'rails_param/param'
require 'action_controller'

class MyController < ActionController::Base
  include RailsParam::Param

  def params; end
end

describe RailsParam::Param do

  describe ".param!" do
    let(:controller) { MyController.new }
    it "defines the method" do
      controller.should respond_to(:param!)
    end
  end
end

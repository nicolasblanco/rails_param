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
      expect(controller).to respond_to(:param!)
    end

    describe "transform" do
      context "with a method" do
        it "transforms the value" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          controller.param! :word, String, transform: :upcase
          expect(controller.params["word"]).to eql("FOO")
        end
      end

      context "with a block" do
        it "transforms the value" do
          allow(controller).to receive(:params).and_return({ "word" => "FOO" })
          controller.param! :word, String, transform: lambda { |n| n.downcase }
          expect(controller.params["word"]).to eql("foo")
        end
      end
    end

    describe "default" do
      context "with a value" do
        it "defaults to the value" do
          allow(controller).to receive(:params).and_return({ })
          controller.param! :word, String, default: "foo"
          expect(controller.params["word"]).to eql("foo")
        end
      end

      context "with a block" do
        it "defaults to the block value" do
          allow(controller).to receive(:params).and_return({ })
          controller.param! :word, String, default: lambda { "foo" }
          expect(controller.params["word"]).to eql("foo")
        end
      end
    end

    describe "coerce" do
      it "converts to String" do
        allow(controller).to receive(:params).and_return({ "foo" => :bar })
        controller.param! :foo, String
        expect(controller.params["foo"]).to eql("bar")
      end

      it "converts to Integer" do
        allow(controller).to receive(:params).and_return({ "foo" => "42" })
        controller.param! :foo, Integer
        expect(controller.params["foo"]).to eql(42)
      end

      it "converts to Float" do
        allow(controller).to receive(:params).and_return({ "foo" => "42.22" })
        controller.param! :foo, Float
        expect(controller.params["foo"]).to eql(42.22)
      end

      it "converts to Array" do
        allow(controller).to receive(:params).and_return({ "foo" => "2,3,4,5" })
        controller.param! :foo, Array
        expect(controller.params["foo"]).to eql(["2", "3", "4", "5"])
      end

      it "converts to Hash" do
        allow(controller).to receive(:params).and_return({ "foo" => "key1:foo,key2:bar" })
        controller.param! :foo, Hash
        expect(controller.params["foo"]).to eql({ "key1" => "foo", "key2" => "bar" })
      end

      it "converts to Date" do
        allow(controller).to receive(:params).and_return({ "foo" => "1984-01-10" })
        controller.param! :foo, Date
        expect(controller.params["foo"]).to eql(Date.parse("1984-01-10"))
      end

      it "converts to Time" do
        allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
        controller.param! :foo, Time
        expect(controller.params["foo"]).to eql(Time.parse("2014-08-07T12:25:00.000+02:00"))
      end

      it "converts to DateTime" do
        allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
        controller.param! :foo, DateTime
        expect(controller.params["foo"]).to eql(DateTime.parse("2014-08-07T12:25:00.000+02:00"))
      end

      describe "booleans" do
        it "converts 1/0" do
          allow(controller).to receive(:params).and_return({ "foo" => "1" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({ "foo" => "0" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts true/false" do
          allow(controller).to receive(:params).and_return({ "foo" => "true" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({ "foo" => "false" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts t/f" do
          allow(controller).to receive(:params).and_return({ "foo" => "t" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({ "foo" => "f" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts yes/no" do
          allow(controller).to receive(:params).and_return({ "foo" => "yes" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({ "foo" => "no" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts y/n" do
          allow(controller).to receive(:params).and_return({ "foo" => "y" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({ "foo" => "n" })
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end
      end

      it "raises InvalidParameterError if the value is invalid" do
        allow(controller).to receive(:params).and_return({ "foo" => "1984-01-32" })
        expect { controller.param! :foo, Date }.to raise_error(RailsParam::Param::InvalidParameterError)
      end
    end

    describe "validation" do
      describe "required parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, required: true }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ })
          expect { controller.param! :price, Integer, required: true }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "blank parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, String, blank: false }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "" })
          expect { controller.param! :price, String, blank: false }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "format parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50$" })
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "is parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, String, is: "50" }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "51" })
          expect { controller.param! :price, String, is: "50" }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "min parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, min: 50 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, min: 51 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "max parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, max: 50 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, max: 49 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "min_length parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, min_length: 3 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, min_length: 4 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "max_length parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, max_length: 3 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, max_length: 2 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "in, within, range parameters" do
        before(:each) { allow(controller).to receive(:params).and_return({ "price" => "50" }) }

        it "succeeds in the range" do
          controller.param! :price, Integer, in: 1..100
          expect(controller.params["price"]).to eql(50)
        end

        it "raises outside the range" do
          expect { controller.param! :price, Integer, in: 51..100 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end
    end
  end
end

require 'spec_helper'

if RUBY_VERSION >= '2.6.0' and Rails.version < '5'
  class ActionController::TestResponse < ActionDispatch::TestResponse
    def recycle!
      # hack to avoid MonitorMixin double-initialize error:
      @mon_mutex_owner_object_id = nil
      @mon_mutex = nil
      initialize
    end
  end
end

class MyController < ActionController::Base
  include RailsParam

  def params;
  end
end

describe RailsParam do
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

        it "transforms default value" do
          allow(controller).to receive(:params).and_return({})
          controller.param! :word, String, default: "foo", transform: :upcase
          expect(controller.params["word"]).to eql("FOO")
        end
      end

      context "with a block" do
        it "transforms the value" do
          allow(controller).to receive(:params).and_return({ "word" => "FOO" })
          controller.param! :word, String, transform: lambda { |n| n.downcase }
          expect(controller.params["word"]).to eql("foo")
        end

        it "transforms default value" do
          allow(controller).to receive(:params).and_return({})
          controller.param! :word, String, default: "foo", transform: lambda { |n| n.upcase }
          expect(controller.params["word"]).to eql("FOO")
        end

        it "transforms falsey value" do
          allow(controller).to receive(:params).and_return({ "foo" => "0" })
          controller.param! :foo, :boolean, transform: lambda { |n| n ? "bar" : "no bar" }
          expect(controller.params["foo"]).to eql("no bar")
        end
      end

      context "when param is required & not present" do
        it "doesn't transform the value" do
          allow(controller).to receive(:params).and_return({ "foo" => nil })
          expect { controller.param! :foo, String, required: true, transform: :upcase }.to raise_error(RailsParam::InvalidParameterError, "Parameter foo is required")
        end
      end
    end

    describe "default" do
      context "with a value" do
        it "defaults to the value" do
          allow(controller).to receive(:params).and_return({})
          controller.param! :word, String, default: "foo"
          expect(controller.params["word"]).to eql("foo")
        end

        it "does not default to the value if value already provided" do
          allow(controller).to receive(:params).and_return({ "word" => "bar" })
          controller.param! :word, String, default: "foo"
          expect(controller.params["word"]).to eql("bar")
        end
      end

      context "with a block" do
        it "defaults to the block value" do
          allow(controller).to receive(:params).and_return({})
          controller.param! :foo, :boolean, default: lambda { false }
          expect(controller.params["foo"]).to eql(false)
        end

        it "does not default to the value if value already provided" do
          allow(controller).to receive(:params).and_return({ "foo" => "bar" })
          controller.param! :foo, String, default: lambda { 'not bar' }
          expect(controller.params["foo"]).to eql("bar")
        end
      end
    end

    describe "coerce" do
      describe "String" do
        it "will convert to String" do
          allow(controller).to receive(:params).and_return({ "foo" => :bar })
          controller.param! :foo, String
          expect(controller.params["foo"]).to eql("bar")
        end
      end

      describe "Integer" do
        it "will convert to Integer if the value is valid" do
          allow(controller).to receive(:params).and_return({ "foo" => "42" })
          controller.param! :foo, Integer
          expect(controller.params["foo"]).to eql(42)
        end

        it "will raise InvalidParameterError if the value is not valid" do
          allow(controller).to receive(:params).and_return({ "foo" => "notInteger" })
          expect { controller.param! :foo, Integer }.to raise_error(RailsParam::InvalidParameterError, "'notInteger' is not a valid Integer")
        end

        it "will raise InvalidParameterError if the value is a boolean" do
          allow(controller).to receive(:params).and_return({ "foo" => true })
          expect { controller.param! :foo, Integer }.to raise_error(RailsParam::InvalidParameterError, "'true' is not a valid Integer")
        end
      end

      describe "Float" do
        it "will convert to Float" do
          allow(controller).to receive(:params).and_return({ "foo" => "42.22" })
          controller.param! :foo, Float
          expect(controller.params["foo"]).to eql(42.22)
        end

        it "will raise InvalidParameterError if the value is not valid" do
          allow(controller).to receive(:params).and_return({ "foo" => "notFloat" })
          expect { controller.param! :foo, Float }.to raise_error(RailsParam::InvalidParameterError, "'notFloat' is not a valid Float")
        end

        it "will raise InvalidParameterError if the value is a boolean" do
          allow(controller).to receive(:params).and_return({ "foo" => true })
          expect { controller.param! :foo, Float }.to raise_error(RailsParam::InvalidParameterError, "'true' is not a valid Float")
        end
      end

      describe "Array" do
        it "will convert to Array" do
          allow(controller).to receive(:params).and_return({ "foo" => "2,3,4,5" })
          controller.param! :foo, Array
          expect(controller.params["foo"]).to eql(["2", "3", "4", "5"])
        end

        it "will raise InvalidParameterError if the value is a boolean" do
          allow(controller).to receive(:params).and_return({ "foo" => true })
          expect { controller.param! :foo, Array }.to raise_error(RailsParam::InvalidParameterError, "'true' is not a valid Array")
        end
      end

      describe "Hash" do
        it "will convert to Hash" do
          allow(controller).to receive(:params).and_return({ "foo" => "key1:foo,key2:bar" })
          controller.param! :foo, Hash
          expect(controller.params["foo"]).to eql({ "key1" => "foo", "key2" => "bar" })
        end

        it "will raise InvalidParameterError if the value is a boolean" do
          allow(controller).to receive(:params).and_return({ "foo" => true })
          expect { controller.param! :foo, Hash }.to raise_error(RailsParam::InvalidParameterError, "'true' is not a valid Hash")
        end
      end

      describe "Date" do
        context "default condition" do
          it "will convert to DateTime" do
            allow(controller).to receive(:params).and_return({ "foo" => "1984-01-10" })
            controller.param! :foo, Date
            expect(controller.params["foo"]).to eql(Date.new(1984, 1, 10))
          end

          it "will raise InvalidParameterError if the value is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "notDate" })
            expect { controller.param! :foo, Date }.to raise_error(RailsParam::InvalidParameterError, "'notDate' is not a valid Date")
          end
        end

        context "with format" do
          it "will convert to DateTime" do
            allow(controller).to receive(:params).and_return({ "foo" => "1984-01-10T12:25:00.000+02:00" })
            controller.param! :foo, Date, format: "%F"
            expect(controller.params["foo"]).to eql(Date.new(1984, 1, 10))
          end

          it "will raise InvalidParameterError if the value is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "notDate" })
            expect { controller.param! :foo, DateTime, format: "%F" }.to(
              raise_error(RailsParam::InvalidParameterError, "'notDate' is not a valid DateTime")
            )
          end

          it "will raise InvalidParameterError if the format is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "1984-01-10" })
            expect { controller.param! :foo, DateTime, format: "%x" }.to(
              raise_error(RailsParam::InvalidParameterError, "'1984-01-10' is not a valid DateTime")
            )
          end
        end
      end

      describe "Time" do
        context "default condition" do
          it "will convert to Time" do
            allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
            controller.param! :foo, Time
            expect(controller.params["foo"]).to eql(Time.new(2014, 8, 7, 12, 25, 0, 7200))
          end

          it "will raise InvalidParameterError if the value is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "notTime" })
            expect { controller.param! :foo, Time }.to raise_error(RailsParam::InvalidParameterError, "'notTime' is not a valid Time")
          end
        end

        context "with format" do
          it "will convert to Time" do
            allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
            controller.param! :foo, Time, format: "%F"
            expect(controller.params["foo"]).to eql(Time.new(2014, 8, 7))
          end

          it "will raise InvalidParameterError if the value is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "notDate" })
            expect { controller.param! :foo, Time, format: "%F" }.to(
              raise_error(RailsParam::InvalidParameterError, "'notDate' is not a valid Time")
            )
          end

          it "will raise InvalidParameterError if the format is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
            expect { controller.param! :foo, Time, format: "%x" }.to(
              raise_error(RailsParam::InvalidParameterError, "'2014-08-07T12:25:00.000+02:00' is not a valid Time")
            )
          end
        end
      end

      describe "DateTime" do
        context "default condition" do
          it "will convert to DateTime" do
            allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
            controller.param! :foo, DateTime
            expect(controller.params["foo"]).to eql(DateTime.new(2014, 8, 7, 12, 25, 0, '+2'))
          end

          it "will raise InvalidParameterError if the value is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "notTime" })
            expect { controller.param! :foo, DateTime }.to raise_error(RailsParam::InvalidParameterError, "'notTime' is not a valid DateTime")
          end
        end

        context "with format" do
          it "will convert to DateTime" do
            allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
            controller.param! :foo, DateTime, format: "%F"
            expect(controller.params["foo"]).to eql(DateTime.new(2014, 8, 7))
          end

          it "will raise InvalidParameterError if the value is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "notDate" })
            expect { controller.param! :foo, DateTime, format: "%F" }.to(
              raise_error(RailsParam::InvalidParameterError, "'notDate' is not a valid DateTime")
            )
          end

          it "will raise InvalidParameterError if the format is not valid" do
            allow(controller).to receive(:params).and_return({ "foo" => "2014-08-07T12:25:00.000+02:00" })
            expect { controller.param! :foo, DateTime, format: "%x" }.to(
              raise_error(RailsParam::InvalidParameterError, "'2014-08-07T12:25:00.000+02:00' is not a valid DateTime")
            )
          end
        end
      end

      describe "BigDecimals" do
        it "converts to BigDecimal using default precision" do
          allow(controller).to receive(:params).and_return({ "foo" => 12345.67890123456 })
          controller.param! :foo, BigDecimal
          expect(controller.params["foo"]).to eql 12345.678901235
        end

        it "converts to BigDecimal using precision option" do
          allow(controller).to receive(:params).and_return({ "foo" => 12345.6789 })
          controller.param! :foo, BigDecimal, precision: 6
          expect(controller.params["foo"]).to eql 12345.7
        end

        it "converts formatted currency string to big decimal" do
          allow(controller).to receive(:params).and_return({ "foo" => "$100,000" })
          controller.param! :foo, BigDecimal
          expect(controller.params["foo"]).to eql 100000.0
        end
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

        it "return InvalidParameterError if value not boolean" do
          allow(controller).to receive(:params).and_return({ "foo" => "1111" })
          expect { controller.param! :foo, :boolean }.to raise_error(RailsParam::InvalidParameterError, "'1111' is not a valid boolean")
        end

        it "set default boolean" do
          allow(controller).to receive(:params).and_return({})
          controller.param! :foo, :boolean, default: false
          expect(controller.params["foo"]).to eql(false)
        end
      end

      describe "Arrays" do
        it "will handle nil" do
          allow(controller).to receive(:params).and_return({ "foo" => nil })
          expect { controller.param! :foo, Array }.not_to raise_error
        end
      end

      describe "UploadedFiles" do
        it "will handle nil" do
          allow(controller).to receive(:params).and_return({ "foo" => nil })
          expect { controller.param! :foo, ActionDispatch::Http::UploadedFile }.not_to raise_error
        end
      end
    end

    describe 'validating nested hash' do
      it 'typecasts nested attributes' do
        allow(controller).to receive(:params).and_return({ 'foo' => { 'bar' => 1, 'baz' => 2 } })
        controller.param! :foo, Hash do |p|
          p.param! :bar, BigDecimal
          p.param! :baz, Float
        end
        expect(controller.params['foo']['bar']).to be_instance_of BigDecimal
        expect(controller.params['foo']['baz']).to be_instance_of Float
      end

      it 'does not raise exception if hash is not required but nested attributes are, and no hash is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)
        controller.param! :foo, Hash do |p|
          p.param! :bar, BigDecimal, required: true
          p.param! :baz, Float, required: true
        end
        expect(controller.params['foo']).to be_nil
      end

      it 'raises exception if hash is required, nested attributes are not required, and no hash is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)

        expect {
          controller.param! :foo, Hash, required: true do |p|
            p.param! :bar, BigDecimal
            p.param! :baz, Float
          end
        }.to raise_error(RailsParam::InvalidParameterError, "Parameter foo is required")
      end

      it 'raises exception if hash is not required but nested attributes are, and hash has missing attributes' do
        allow(controller).to receive(:params).and_return({ 'foo' => { 'bar' => 1, 'baz' => nil } })
        expect {
          controller.param! :foo, Hash do |p|
            p.param! :bar, BigDecimal, required: true
            p.param! :baz, Float, required: true
          end
        }.to raise_error(RailsParam::InvalidParameterError, "Parameter foo[baz] is required")
      end
    end

    describe 'validating arrays' do
      it 'typecasts array of primitive elements' do
        allow(controller).to receive(:params).and_return({ 'array' => ['1', '2'] })
        controller.param! :array, Array do |a, i|
          a.param! i, Integer, required: true
        end
        expect(controller.params['array'][0]).to be_a Integer
        expect(controller.params['array'][1]).to be_a Integer
      end

      it 'validates array of hashes' do
        params = { 'array' => [{ 'object' => { 'num' => '1', 'float' => '1.5' } }, { 'object' => { 'num' => '2', 'float' => '2.3' } }] }
        allow(controller).to receive(:params).and_return(params)
        controller.param! :array, Array do |a|
          a.param! :object, Hash do |h|
            h.param! :num, Integer, required: true
            h.param! :float, Float, required: true
          end
        end
        expect(controller.params['array'][0]['object']['num']).to be_a Integer
        expect(controller.params['array'][0]['object']['float']).to be_instance_of Float
        expect(controller.params['array'][1]['object']['num']).to be_a Integer
        expect(controller.params['array'][1]['object']['float']).to be_instance_of Float
      end

      it 'validates an array of arrays' do
        params = { 'array' => [['1', '2'], ['3', '4']] }
        allow(controller).to receive(:params).and_return(params)
        controller.param! :array, Array do |a, i|
          a.param! i, Array do |b, e|
            b.param! e, Integer, required: true
          end
        end
        expect(controller.params['array'][0][0]).to be_a Integer
        expect(controller.params['array'][0][1]).to be_a Integer
        expect(controller.params['array'][1][0]).to be_a Integer
        expect(controller.params['array'][1][1]).to be_a Integer
      end

      it 'raises exception when primitive element missing' do
        allow(controller).to receive(:params).and_return({ 'array' => ['1', nil] })
        expect {
          controller.param! :array, Array do |a, i|
            a.param! i, Integer, required: true
          end
        }.to raise_error(RailsParam::InvalidParameterError, "Parameter array[1] is required")
      end

      it 'raises exception when nested hash element missing' do
        params = { 'array' => [{ 'object' => { 'num' => '1', 'float' => nil } }, { 'object' => { 'num' => '2', 'float' => '2.3' } }] }
        allow(controller).to receive(:params).and_return(params)
        expect {
          controller.param! :array, Array do |a|
            a.param! :object, Hash do |h|
              h.param! :num, Integer, required: true
              h.param! :float, Float, required: true
            end
          end
        }.to raise_error(RailsParam::InvalidParameterError, "Parameter array[0][object][float] is required")
      end

      it 'raises exception when nested array element missing' do
        params = { 'array' => [['1', '2'], ['3', nil]] }
        allow(controller).to receive(:params).and_return(params)
        expect {
          controller.param! :array, Array do |a, i|
            a.param! i, Array do |b, e|
              b.param! e, Integer, required: true
            end
          end
        }.to raise_error(RailsParam::InvalidParameterError, "Parameter array[1][1] is required")
      end

      it 'does not raise exception if array is not required but nested attributes are, and no array is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)
        controller.param! :foo, Array do |p|
          p.param! :bar, BigDecimal, required: true
          p.param! :baz, Float, required: true
        end
        expect(controller.params['foo']).to be_nil
      end

      it 'raises exception if array is required, nested attributes are not required, and no array is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)
        expect {
          controller.param! :foo, Array, required: true do |p|
            p.param! :bar, BigDecimal
            p.param! :baz, Float
          end
        }.to raise_error(RailsParam::InvalidParameterError, "Parameter foo is required")
      end
    end

    describe "validation" do
      describe "required parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, required: true }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :price, Integer, required: true }.to raise_error(RailsParam::InvalidParameterError, "Parameter price is required")
        end

        it "raises custom message" do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :price, Integer, required: true, message: "No price specified" }.to raise_error(RailsParam::InvalidParameterError, "No price specified")
        end
      end

      describe "blank parameter" do
        it "succeeds with not empty String" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, String, blank: false }.to_not raise_error
        end

        it "raises with empty String" do
          allow(controller).to receive(:params).and_return({ "price" => "" })
          expect { controller.param! :price, String, blank: false }.to raise_error(RailsParam::InvalidParameterError, "Parameter price cannot be blank")
        end

        it "succeeds with not empty Hash" do
          allow(controller).to receive(:params).and_return({ "hash" => { "price" => "50" } })
          expect { controller.param! :hash, Hash, blank: false }.to_not raise_error
        end

        it "raises with empty Hash" do
          allow(controller).to receive(:params).and_return({ "hash" => {} })
          expect { controller.param! :hash, Hash, blank: false }.to raise_error(RailsParam::InvalidParameterError, "Parameter hash cannot be blank")
        end

        it "succeeds with not empty Array" do
          allow(controller).to receive(:params).and_return({ "array" => [50] })
          expect { controller.param! :array, Array, blank: false }.to_not raise_error
        end

        it "raises with empty Array" do
          allow(controller).to receive(:params).and_return({ "array" => [] })
          expect { controller.param! :array, Array, blank: false }.to raise_error(RailsParam::InvalidParameterError, "Parameter array cannot be blank")
        end

        it "succeeds with not empty ActiveController::Parameters" do
          allow(controller).to receive(:params).and_return({ "hash" => ActionController::Parameters.new({ "price" => "50" }) })
          expect { controller.param! :hash, Hash, blank: false }.to_not raise_error
        end

        it "raises with empty ActiveController::Parameters" do
          allow(controller).to receive(:params).and_return({ "hash" => ActionController::Parameters.new() })
          expect { controller.param! :hash, Hash, blank: false }.to raise_error(RailsParam::InvalidParameterError, "Parameter hash cannot be blank")
        end
      end

      describe "format parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50$" })
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to raise_error(RailsParam::InvalidParameterError, "Parameter price must match format #{/[0-9]+\$/}")
        end
      end

      describe "is parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, String, is: "50" }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "51" })
          expect { controller.param! :price, String, is: "50" }.to raise_error(RailsParam::InvalidParameterError, "Parameter price must be 50")
        end
      end

      describe "min parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, min: 50 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, min: 51 }.to raise_error(RailsParam::InvalidParameterError, "Parameter price cannot be less than 51")
        end
      end

      describe "max parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, max: 50 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "price" => "50" })
          expect { controller.param! :price, Integer, max: 49 }.to raise_error(RailsParam::InvalidParameterError, "Parameter price cannot be greater than 49")
        end
      end

      describe "min_length parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, min_length: 3 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, min_length: 4 }.to raise_error(RailsParam::InvalidParameterError, "Parameter word cannot have length less than 4")
        end
      end

      describe "max_length parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, max_length: 3 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({ "word" => "foo" })
          expect { controller.param! :word, String, max_length: 2 }.to raise_error(RailsParam::InvalidParameterError, "Parameter word cannot have length greater than 2")
        end
      end

      describe "in, within, range parameters" do
        before(:each) { allow(controller).to receive(:params).and_return({ "price" => "50" }) }

        it "succeeds in the range" do
          controller.param! :price, Integer, in: 1..100
          expect(controller.params["price"]).to eql(50)
        end

        it "raises outside the range" do
          expect { controller.param! :price, Integer, in: 51..100 }.to raise_error(RailsParam::InvalidParameterError, "Parameter price must be within 51..100")
        end
      end

      describe "custom validator" do
        let(:custom_validation) { lambda { |v| raise RailsParam::InvalidParameterError, 'Number is not even' if v % 2 != 0 } }

        it "succeeds when valid" do
          allow(controller).to receive(:params).and_return({ "number" => "50" })
          controller.param! :number, Integer, custom: custom_validation
          expect(controller.params["number"]).to eql(50)
        end

        it "raises when invalid" do
          allow(controller).to receive(:params).and_return({ "number" => "51" })
          expect do
            controller.param! :number, Integer, custom: custom_validation
          end.to raise_error(RailsParam::InvalidParameterError, 'Number is not even')
        end
      end
    end
  end
end

require 'rails_param/param'
require 'action_controller'

class MyController < ActionController::Base
  include RailsParam::Param

  def params;
  end
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
          allow(controller).to receive(:params).and_return({"word" => "foo"})
          controller.param! :word, String, transform: :upcase
          expect(controller.params["word"]).to eql("FOO")
        end
      end

      context "with a block" do
        it "transforms the value" do
          allow(controller).to receive(:params).and_return({"word" => "FOO"})
          controller.param! :word, String, transform: lambda { |n| n.downcase }
          expect(controller.params["word"]).to eql("foo")
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
      end

      context "with a block" do
        it "defaults to the block value" do
          allow(controller).to receive(:params).and_return({})
          controller.param! :word, String, default: lambda { "foo" }
          expect(controller.params["word"]).to eql("foo")
        end
      end
    end

    describe "coerce" do
      it "converts to String" do
        allow(controller).to receive(:params).and_return({"foo" => :bar})
        controller.param! :foo, String
        expect(controller.params["foo"]).to eql("bar")
      end

      it "converts to Integer" do
        allow(controller).to receive(:params).and_return({"foo" => "42"})
        controller.param! :foo, Integer
        expect(controller.params["foo"]).to eql(42)
      end

      it "converts to Float" do
        allow(controller).to receive(:params).and_return({"foo" => "42.22"})
        controller.param! :foo, Float
        expect(controller.params["foo"]).to eql(42.22)
      end

      it "converts to Array" do
        allow(controller).to receive(:params).and_return({"foo" => "2,3,4,5"})
        controller.param! :foo, Array
        expect(controller.params["foo"]).to eql(["2", "3", "4", "5"])
      end

      it "converts to Hash" do
        allow(controller).to receive(:params).and_return({"foo" => "key1:foo,key2:bar"})
        controller.param! :foo, Hash
        expect(controller.params["foo"]).to eql({"key1" => "foo", "key2" => "bar"})
      end

      it "converts to Date" do
        allow(controller).to receive(:params).and_return({"foo" => "1984-01-10"})
        controller.param! :foo, Date
        expect(controller.params["foo"]).to eql(Date.parse("1984-01-10"))
      end

      it "converts to Time" do
        allow(controller).to receive(:params).and_return({"foo" => "2014-08-07T12:25:00.000+02:00"})
        controller.param! :foo, Time
        expect(controller.params["foo"]).to eql(Time.parse("2014-08-07T12:25:00.000+02:00"))
      end

      it "converts to DateTime" do
        allow(controller).to receive(:params).and_return({"foo" => "2014-08-07T12:25:00.000+02:00"})
        controller.param! :foo, DateTime
        expect(controller.params["foo"]).to eql(DateTime.parse("2014-08-07T12:25:00.000+02:00"))
      end

      describe "BigDecimals" do
        it "converts to BigDecimal using default precision" do
          allow(controller).to receive(:params).and_return({"foo" => 12345.67890123456})
          controller.param! :foo, BigDecimal
          expect(controller.params["foo"]).to eql 12345.678901235
        end

        it "converts to BigDecimal using precision option" do
          allow(controller).to receive(:params).and_return({"foo" => 12345.6789})
          controller.param! :foo, BigDecimal, precision: 6
          expect(controller.params["foo"]).to eql 12345.7
        end

        it "converts formatted currency string to big decimal" do
          allow(controller).to receive(:params).and_return({"foo" => "$100,000"})
          controller.param! :foo, BigDecimal
          expect(controller.params["foo"]).to eql 100000.0
        end

      end

      describe "booleans" do
        it "converts 1/0" do
          allow(controller).to receive(:params).and_return({"foo" => "1"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({"foo" => "0"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts true/false" do
          allow(controller).to receive(:params).and_return({"foo" => "true"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({"foo" => "false"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts t/f" do
          allow(controller).to receive(:params).and_return({"foo" => "t"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({"foo" => "f"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts yes/no" do
          allow(controller).to receive(:params).and_return({"foo" => "yes"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({"foo" => "no"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "converts y/n" do
          allow(controller).to receive(:params).and_return({"foo" => "y"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(true)

          allow(controller).to receive(:params).and_return({"foo" => "n"})
          controller.param! :foo, TrueClass
          expect(controller.params["foo"]).to eql(false)
        end

        it "return InvalidParameterError if value not boolean" do
          allow(controller).to receive(:params).and_return({"foo" => "1111"})
          expect { controller.param! :foo, :boolean }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
        it "set default boolean" do
          allow(controller).to receive(:params).and_return({})
          controller.param! :foo, :boolean, default: false
          expect(controller.params["foo"]).to eql(false)
        end
      end

      it "raises InvalidParameterError if the value is invalid" do
        allow(controller).to receive(:params).and_return({"foo" => "1984-01-32"})
        expect { controller.param! :foo, Date }.to raise_error(RailsParam::Param::InvalidParameterError)
      end

    end

    describe 'validating nested hash' do
      it 'typecasts nested attributes' do
        allow(controller).to receive(:params).and_return({'foo' => {'bar' => 1, 'baz' => 2}})
        controller.param! :foo, Hash do |p|
          p.param! :bar, BigDecimal
          p.param! :baz, Float
        end
        expect(controller.params['foo']['bar']).to be_instance_of BigDecimal
        expect(controller.params['foo']['baz']).to be_instance_of Float
      end

      it 'raises exception if provided value is not a hash' do
        allow(controller).to receive(:params).and_return(foo: [])
        expect {
          controller.param! :foo, Hash, required: true do |p|
            p.param! :bar, BigDecimal
            p.param! :baz, Float
          end
        }.to raise_exception(RailsParam::Param::InvalidParameterError)
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
        }.to raise_exception
      end

      it 'raises exception if hash is not required but nested attributes are, and hash has missing attributes' do
        allow(controller).to receive(:params).and_return({'foo' => {'bar' => 1, 'baz' => nil}})
        expect {
          controller.param! :foo, Hash do |p|
            p.param! :bar, BigDecimal, required: true
            p.param! :baz, Float, required: true
          end
        }.to raise_exception
      end
    end

    describe 'validating arrays' do
      it 'typecasts array of primitive elements' do
        allow(controller).to receive(:params).and_return({'array' => ['1', '2']})
        controller.param! :array, Array do |a, i|
          a.param! i, Integer, required: true
        end
        expect(controller.params['array'][0]).to be_a Integer
        expect(controller.params['array'][1]).to be_a Integer
      end

      it 'validates array of hashes' do
        params = {'array' => [{'object'=>{ 'num' => '1', 'float' => '1.5' }},{'object'=>{ 'num' => '2', 'float' => '2.3' }}] }
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
        params = {'array' => [[ '1', '2' ],[ '3', '4' ]] }
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
        allow(controller).to receive(:params).and_return({'array' => ['1', nil]})
        expect {
          controller.param! :array, Array do |a, i|
            a.param! i, Integer, required: true
          end
        }.to raise_exception
      end

      it 'raises exception when nested hash element missing' do
        params = {'array' => [{'object'=>{ 'num' => '1', 'float' => nil }},{'object'=>{ 'num' => '2', 'float' => '2.3' }}] }
        allow(controller).to receive(:params).and_return(params)
        expect {
          controller.param! :array, Array do |a|
            a.param! :object, Hash do |h|
              h.param! :num, Integer, required: true
              h.param! :float, Float, required: true
            end
          end
        }.to raise_exception
      end

      it 'raises exception when nested array element missing' do
        params = {'array' => [[ '1', '2' ],[ '3', nil ]] }
        allow(controller).to receive(:params).and_return(params)
        expect {
          controller.param! :array, Array do |a, i|
            a.param! i, Array do |b, e|
              b.param! e, Integer, required: true
            end
          end
        }.to raise_exception
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
        }.to raise_exception
      end

      it 'raises exception if its not an array' do
        allow(controller).to receive(:params).and_return(foo: "test")
        expect {
          controller.param! :foo, Array, required: true do |p|
            p.param! :baz, Float
          end
        }.to raise_exception(RailsParam::Param::InvalidParameterError)
      end
    end

    describe "validation" do
      describe "required parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, Integer, required: true }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :price, Integer, required: true }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "blank parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, String, blank: false }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({"price" => ""})
          expect { controller.param! :price, String, blank: false }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "format parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"price" => "50$"})
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "is parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, String, is: "50" }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({"price" => "51"})
          expect { controller.param! :price, String, is: "50" }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "min parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, Integer, min: 50 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, Integer, min: 51 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "max parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, Integer, max: 50 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({"price" => "50"})
          expect { controller.param! :price, Integer, max: 49 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "min_length parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"word" => "foo"})
          expect { controller.param! :word, String, min_length: 3 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({"word" => "foo"})
          expect { controller.param! :word, String, min_length: 4 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "max_length parameter" do
        it "succeeds" do
          allow(controller).to receive(:params).and_return({"word" => "foo"})
          expect { controller.param! :word, String, max_length: 3 }.to_not raise_error
        end

        it "raises" do
          allow(controller).to receive(:params).and_return({"word" => "foo"})
          expect { controller.param! :word, String, max_length: 2 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "in, within, range parameters" do
        before(:each) { allow(controller).to receive(:params).and_return({"price" => "50"}) }

        it "succeeds in the range" do
          controller.param! :price, Integer, in: 1..100
          expect(controller.params["price"]).to eql(50)
        end

        it "raises outside the range" do
          expect { controller.param! :price, Integer, in: 51..100 }.to raise_error(RailsParam::Param::InvalidParameterError)
        end
      end

      describe "custom validator" do
        class EvenNumberValidator
          def self.validate!(value)
            if(value % 2 != 0)
              raise RailsParam::Param::InvalidParameterError, 'Number is not even'
            end
          end
        end

        it "succeeds when valid" do
          allow(controller).to receive(:params).and_return({"number" => "50"})
          controller.param! :number, Integer, custom: EvenNumberValidator
          expect(controller.params["number"]).to eql(50)
        end

        it "raises when invalid" do
          allow(controller).to receive(:params).and_return({"number" => "51"})
          expect do
            controller.param! :number, Integer, custom: EvenNumberValidator
          end.to raise_error(RailsParam::Param::InvalidParameterError, 'Number is not even')
        end
      end
    end

    describe 'exception full_path_array' do
      it 'has the proper full path with single param check' do
        allow(controller).to receive(:params).and_return({"price" => "abc"})
        begin
          controller.param! :price, Integer, required: true
        rescue RailsParam::Param::InvalidParameterError => e
          expect(e.full_path_array).to eql ["price"]
        end
      end

      it 'has the proper full path when using arrays with hashes' do
        params = {
          'array' => [
            {'object'=>{ 'num' => '1', 'float' => '1.4' }},
            {'object'=>{ 'num' => '2', 'float' => 'abc' }}
          ]
        }
        allow(controller).to receive(:params).and_return(params)
        begin
          controller.param! :array, Array do |a|
            a.param! :object, Hash do |h|
              h.param! :num, Integer, required: true
              h.param! :float, Float, required: true
            end
          end
        rescue RailsParam::Param::InvalidParameterError => e
          expect(e.full_path_array).to eql  ["array", 1, "object", "float"]
        end
      end

      it 'has the proper full path when using arrays with primitive types' do
        params = {
          'array' => ["abc"]
        }
        allow(controller).to receive(:params).and_return(params)
        begin
          controller.param! :array, Array do |array, index|
            array.param! index, Integer, :required => true
          end
        rescue RailsParam::Param::InvalidParameterError => e
          expect(e.full_path_array).to eql ['array', 0]
        end
      end

      it 'has the proper full path when using hashes' do
        params = {
          'hash' => {
            'hash2'=> {'integers' => ['123', 'abc'] }
          }
        }
        allow(controller).to receive(:params).and_return(params)
        begin
          controller.param! :hash, Hash do |a|
            a.param! :hash2, Hash do |h|
              h.param! :integers, Array do |array, index|
                array.param! index, Integer
              end
            end
          end
        rescue RailsParam::Param::InvalidParameterError => e
          expect(e.full_path_array).to eql ["hash", "hash2", "integers", 1]
        end
      end
    end

    describe 'full_path' do
      it 'has the correct full path for root level item' do
        e = RailsParam::Param::InvalidParameterError.new('error')
        e.full_path_array = ["price"]
        expect(e.full_path).to eql "price"
      end

      it 'has the correct full path for nested item' do
        e = RailsParam::Param::InvalidParameterError.new('error')
        e.full_path_array = ["hash", "hash2", "integers", 1]
        expect(e.full_path).to eql "hash[hash2][integers][1]"
      end
    end
  end
end

require 'spec_helper'

describe RailsParam::Param::Validator::Required do
  let(:name)          { "foo" }
  let(:options)       { { blank: false } }
  let(:type)          { String }
  let(:error_message) { "Parameter foo cannot be blank" }
  let(:parameter) do
    RailsParam::Param::Parameter.new(
      name: name,
      value: value,
      options: options,
      type: type
    )
  end

  subject { described_class.new(parameter) }

  describe "#validate!" do
    context "String" do
      context "is not empty" do
        let(:value) { "bar" }

        it_behaves_like "does not raise error"
      end

      context "is empty" do
        let(:value) { "" }

        it_behaves_like "raises InvalidParameterError"
      end
    end

    context "Hash" do
      context "is not empty" do
        let(:value) { { foo: :bar } }

        it_behaves_like "does not raise error"
      end

      context "is empty" do
        let(:value) { {} }

        it_behaves_like "raises InvalidParameterError"
      end
    end

    context "Array" do
      context "is not empty" do
        let(:value) { [50] }

        it_behaves_like "does not raise error"
      end

      context "is empty" do
        let(:value) { [] }

        it_behaves_like "raises InvalidParameterError"
      end
    end

    context "ActiveController::Parameters" do
      context "is not empty" do
        let(:value) do
          ActionController::Parameters.new({ "price" => "50" })
        end

        it_behaves_like "does not raise error"
      end

      context "is empty" do
        let(:value) { ActionController::Parameters.new() }

        it_behaves_like "raises InvalidParameterError"
      end
    end

    context "Integer" do
      context "is not empty" do
        let(:value) { 50 }

        it_behaves_like "does not raise error"
      end

      context "is empty" do
        let(:value) { nil }

        it_behaves_like "raises InvalidParameterError"
      end
    end
  end
end
